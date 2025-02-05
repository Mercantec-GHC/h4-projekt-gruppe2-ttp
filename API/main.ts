import * as oak from "jsr:@oak/oak";
import { Db, Token, token } from "./db.ts";
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

interface stats {
    winratio: number;
    wins: number;
    correctness: number;
    gamesplayed: number;
    lost: number;
}

// Creates user
async function createUser(db: Db, req: RegisterRequest): Promise<Result<void, string>> {
    
    // Retrieves username from input to check if username exists in the database
    const existingUser = db.userFromName(req.username);

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
    const existingUser = db.userFromName(req.username);

    // Checks if the user exists
    if (existingUser === null) {
        return err("No user found");
    }

    // Checks if input-password matches with hashed password in database
    const valid = await HashedPassword.verify({unhashed: req.password, hashed: existingUser.password});
    if (!valid) {
        return err("Incorrect password")
    }

    return ok(token(existingUser.id));
}

async function getUserStats(db: Db, req: string): Promise<Result<void, stats>> {

    if (/*check if the username exists*/) {
        
    }
    const res = db.getUserStats(req);
    return ok();
}

const port = 8000;

const router = new oak.Router();

router.post("/test", async (ctx) => {
    console.log(await ctx.request.body.json());
});

router.post("/createUser", async (ctx) => {
    const req: RegisterRequest = await ctx.request.body.json();

    const db; /* <--- DATABASE CONNECTION */

    // Check if body has text
    if (!req.username || !req.password) {
        ctx.response.body = { ok: false, message: "Please fill out all fields" };
        return;
    }

    // Creates user with createUser()
    const res = (await createUser(db, req)).match(
        (_ok: void) => ({ ok: true, message: "Success" }),
        (err: string) => ({ ok: false, message: err })
    );

    // Responds with the new user
    ctx.response.body = res;
});

router.post("/login", async (ctx)  => {
    const req: LoginRequest = await ctx.request.body.json();

    const db; /* <--- DATABASE CONNECTION */

    // Check if body has text
    if (!req.username || !req.password) {
        ctx.response.body = { ok: false, message: "Please fill out all fields" };
        return;
    }

    // Logs user in with token
    (await login(db, req)).match(token => {
        ctx.response.body = { ok: true, message: "Success", token: token.value };
    }
    , err => {
        ctx.response.body = { ok: false, message: err };
    }
)

});

router.post("/getstats/:user", async (ctx) => {
    if (!ctx.request) {
        ctx.response.body = { ok: false, message: "Missing content" };
    } else {
        const res = (await getUserStats(db, req)).match(
            (_ok: void) => ({ ok: true, message: "Success" }),
            (err: string) => ({ ok: false, message: err })
        );
    }
    if (ctx.request.url) {
        ctx.response.body = { ok: true, message: "User stats" };
    }
});

router.post("/savestats/:user", async (ctx) => {
    
})

const app = new oak.Application();
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
