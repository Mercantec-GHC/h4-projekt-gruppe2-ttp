import * as oak from "jsr:@oak/oak";
import { oakCors } from "https://deno.land/x/cors/mod.ts";
import { Db, Token, token } from "./db.ts";
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

interface GetStatsRequest {
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

interface OutputStats {
  win_ratio: number;
  games_played: number;
  correctness: number;
  wins: number;
  lost: number;
}

async function createUser(
  db: Db,
  req: RegisterRequest,
): Promise<Result<void, string>> {
  const existingUser = await db.user(req.username);

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
  const existingUser = await db.user(req.username);

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
async function getUserStats(
  db: Db,
  req: string,
): Promise<Result<OutputStats, string>> {
  const userStats = await db.userStats(req);

  if (userStats != null) {
    return ok(userStats);
  } else {
    return err("No user found");
  }
}

async function saveUserStats(
  db: Db,
  req: InputStats,
  username: string,
): Promise<Result<string, string>> {
  const res = await db.saveUserStats(username, req);

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

  router.post("/getStats", async (ctx) => {
    const req: GetStatsRequest = await ctx.request.body.json();
    const token = tokens.find((v) => v.value === req.token);
    if (!token) {
      ctx.response.body = { ok: false, message: "Invalid token" };
      return;
    }

    (await getUserStats(db, token.user))
      .match(
        (stats: OutputStats) => {
          ctx.response.body = { ok: true, message: "Success", stats };
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
