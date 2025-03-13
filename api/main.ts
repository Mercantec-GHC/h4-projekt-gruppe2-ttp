import * as oak from "jsr:@oak/oak";
import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";
import { Db, Token, token, User } from "./db.ts";
import { MariaDb } from "./mariadbConnect.ts";
import { err, ok, Result } from "jsr:@result/result";
import { HashedPassword } from "./hashed_password.ts";

interface RegisterRequest {
  username: string;
  password: string;
}

interface LoginRequest {
  username: string;
  password: string;
}

interface UserInfoRequest {
  token: string;
}

interface SaveStatsRequest {
  token: string;
  stats: InputStats;
}

interface InputStats {
  won: boolean;
  correct_answers: number;
  total_answers: number;
}

type OutputStats = {
  correct_answers: number;
  total_answers: number;
  wins: number;
  games_played: number;
};

async function createUser(
  db: Db,
  req: RegisterRequest,
): Promise<Result<void, string>> {
  const existingUser = await db.userFromUsername(req.username);

  if (existingUser !== null) {
    return err("User already exists");
  }

  db.createUser(req.username, await HashedPassword.hash(req.password));
  return ok();
}

async function login(
  db: Db,
  req: LoginRequest,
): Promise<Result<Token, string>> {
  const existingUser = await db.userFromUsername(req.username);

  if (existingUser === null) {
    return err("No user found");
  }

  const valid = await HashedPassword.verify({
    unhashed: req.password,
    hashed: existingUser.password,
  });

  if (!valid) {
    return err("Incorrect password");
  }

  return ok(token(existingUser.id));
}
async function getUser(
  db: Db,
  userId: string,
): Promise<Result<User, string>> {
  const user = await db.user(userId);

  if (user != null) {
    return ok(user);
  } else {
    return err("No user found");
  }
}

async function saveUserStats(
  db: Db,
  stats: InputStats,
  userId: string,
): Promise<Result<string, string>> {
  const res = await db.saveUserStats(userId, stats);

  if (res == null) {
    return ok("Success");
  } else {
    return err("Something went wrong");
  }
}

const port = 8000;

async function main() {
  const router = new oak.Router();
  const db: Db = await MariaDb.connect();
  const tokens: Token[] = [];

  router.post("/createUser", async (ctx) => {
    const req: RegisterRequest = await ctx.request.body.json();

    if (!req.username || !req.password) {
      ctx.response.body = {
        ok: false,
        message: "Please fill out all fields",
      };
      return;
    }

    const res = (await createUser(db, req)).match(
      (_: void) => ({ ok: true, message: "Success" }),
      (err: string) => ({ ok: false, message: err }),
    );

    ctx.response.body = res;
  });

  router.post("/login", async (ctx) => {
    const req: LoginRequest = await ctx.request.body.json();

    if (!req.username || !req.password) {
      ctx.response.body = {
        ok: false,
        message: "Please fill out all fields",
      };
      return;
    }

    (await login(db, req)).match(
      (token) => {
        tokens.push(token);
        ctx.response.body = {
          ok: true,
          message: "Success",
          token: token.value,
        };
      },
      (err) => {
        ctx.response.body = { ok: false, message: err };
      },
    );
  });

  router.post("/user", async (ctx) => {
    const req: UserInfoRequest = await ctx.request.body.json();
    const token = tokens.find((v) => v.value === req.token);
    if (!token) {
      ctx.response.body = { ok: false, message: "Invalid token" };
      return;
    }

    (await getUser(db, token.user))
      .match(
        (user: User) => {
          ctx.response.body = { ok: true, message: "Success", user };
        },
        (err: string) => {
          ctx.response.body = { ok: false, message: err };
        },
      );
  });

  router.post("/saveStats", async (ctx) => {
    const req: SaveStatsRequest = await ctx.request.body.json();
    const token = tokens.find((v) => v.value === req.token);
    if (!token) {
      ctx.response.body = { ok: false, message: "Invalid token" };
      return;
    }

    (await saveUserStats(db, req.stats, token.user)).match(
      (_ok: string) => {
        ctx.response.body = { ok: true, message: "success" };
      },
      (err: string) => {
        ctx.response.body = { ok: false, message: err };
      },
    );
  });

  const app = new oak.Application();
  app.use(oakCors({ credentials: true, origin: "http://localhost:8000" }));
  app.use(router.routes());
  app.use(router.allowedMethods());
  app.use(async (ctx, next) => {
    try {
      await ctx.send({ root: "./public", index: "index.html" });
    } catch {
      next();
    }
  });

  app.addEventListener(
    "listen",
    ({ port }) =>
      console.log(`*bip bop, backend er i top* http://localhost:${port}/`),
  );

  await app.listen({ port });
}

await main();
