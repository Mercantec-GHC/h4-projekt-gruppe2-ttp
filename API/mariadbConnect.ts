import { Db, User, uuid, stats } from "./db.ts";
import { HashedPassword } from "./hashed_password.ts";
import { Client } from "https://deno.land/x/mysql@v2.12.1/mod.ts";

export class mariaDb implements Db {
    private connection: any;

    public static async connect(path: string): Promise<mariaDb> {
        const db = await new Client().connect({
            hostname: "localhost",
            username: "root",
            db: "TriviaCrusader",
            password: "",
        });

        await db.execute("CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, username TEXT, password TEXT)");

        return new mariaDb();
    }

    public createUser(id: string, username: string, password: HashedPassword): null {
        id = uuid();
        this.connection.prepare("INSERT INTO users(id, username, password) VALUES(?, ?, ?, ?)").run(id, username, password.value);
        return null;
    }

    public userFromName(username: string): User | null {
        const user = this.connection.prepare("SELECT * FROM users WHERE username = ?").get(username);
        if (!user) {
            return null;
        }
        return user as User;
    }

    public getUserStats(username: string): stats {
        const result = this.connection.prepare("SELECT * FROM users WHERE username = ?").get(username);
        if (!result) {
            throw new Error(`No stats found for user: ${username}`);
        }
        return result as stats;
    }
}
