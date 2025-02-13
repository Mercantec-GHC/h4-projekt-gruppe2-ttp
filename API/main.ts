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

interface InputStats {
    won: boolean;
    correctanswers: number;
    totalanswers: number;
}

interface OutputStats {
    winratio: number,
    gamesplayed: number,
    correctness: number,
    wins: number,
    losses: number,
}

// Creates user
async function createUser(db: Db, req: RegisterRequest): Promise<Result<void, string>> {
    // Retrieves username from input to check if username exists in the database

    const existingUser = await db.userFromName(req.username);

    // Checks if the user exists
    if (existingUser !== null) {
        return err("User alreay exists");
    }

    // Creates user in the database with the user inputs and hashing the password
    db.createUser(req.username, await HashedPassword.hash(req.password));
    return ok();
}

async function login(db: Db, req: LoginRequest): Promise<Result<Token, string>> {
    // Retrieves username from input to check if username exists in the database
    const existingUser = await db.userFromName(req.username);

    // Checks if the user exists
    if (existingUser === null) {
        return err("No user found");
    }

    // Checks if input-password matches with hashed password in database
    const valid = await HashedPassword.verify({ unhashed: req.password, hashed: existingUser.password });
    if (!valid) {
        return err("Incorrect password");
    }

    return ok(token(existingUser.id));
}
async function getUserStats(db: Db, req: string): Promise<Result<OutputStats, string>> {
    // Retrieves stats from db
    const userStats = await db.getUserStats(req)
    if (userStats != null) {
        return ok(userStats);
     }
} 

async function saveUserStats(db: Db, req: InputStats, username: string): Promise<Result<void | string>> {
    const res = await db.saveUserStats(username, req)
    if (res != null) {
        return err("Something went wrong")
    }
    else {
        return ok();
    }
}

const port = 8000;

const router = new oak.Router();

router.post("/createUser", async (ctx) => {
    const req: RegisterRequest = await ctx.request.body.json();

    // Check if body has text
    if (!req.username || !req.password) {
        ctx.response.body = { ok: false, message: "Please fill out all fields" };
        return;
    }

    // Creates user with createUser()
    const res = (await createUser(await MariaDb.connect(), req)).match(
        (_ok: void) => ({ ok: true, message: "Success" }),
        (err: string) => ({ ok: false, message: err })
    );

    // Responds with the new user
    ctx.response.body = res;
});

router.post("/login", async (ctx) => {
    const req: LoginRequest = await ctx.request.body.json();

    // Check if body has text
    if (!req.username || !req.password) {
        ctx.response.body = { ok: false, message: "Please fill out all fields" };
        return;
    }

    // Logs user in with token
    (await login(await MariaDb.connect(), req)).match(
        (token) => {
            ctx.response.body = { ok: true, message: "Success", token: token.value };
        },
        (err) => {
            ctx.response.body = { ok: false, message: err };
        }
    );
});

router.post("/getstats", async (ctx) => {
    const req = await ctx.request.body.json();
    // checks if request has content
    if (req == null) {
        ctx.response.body = { ok: false, message: "Missing content" };
        return;
    } 

    const res = (await getUserStats(await MariaDb.connect(), req)).match(
        (_ok: OutputStats) => {
            ctx.response.body = { ok: true, message: "Success", stats: res};
        },
        (err: string) => {
            ctx.response.body = { ok: false, message: err };
        }
    );

});


router.post("/savestats/:user", async (ctx) => {
    const user = ctx.params.user
    const req = await ctx.request.body.json()
    if (req == null) {
        ctx.response.body = { ok: true, message: "Unknown request"};
        return;
    }
    
    (await saveUserStats(await MariaDb.connect(), req, user)).match(
        (_ok: string) => {
            ctx.response.body = { ok: true, message: "success"}
        }, 
        (err: string) => {
            ctx.response.body = {ok: false, message: err}
        }
    )
});

const app = new oak.Application();
app.use(oakCors());
app.use(router.routes());
app.use(router.allowedMethods());
app.use(async (ctx, next) => {
    try {
        await ctx.send({ root: "./public", index: "index.html" });
    } catch {
        next();
    }
});

const listener = app.listen({ port });
console.log(`*bip bop, backend er i top* http://localhost:${port}/`);
await listener;
