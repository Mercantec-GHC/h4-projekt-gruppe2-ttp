import { Db, User, uuid, Stats } from "./db.ts";
import { HashedPassword } from "./hashed_password.ts";
import { Client } from "https://deno.land/x/mysql@v2.12.1/mod.ts";

export class MariaDb implements Db {
    private connection: Client;

    private constructor(client: Client) {
        this.connection = client;
    }

    public static async connect(path: string): Promise<MariaDb> {
        const db = await new Client().connect({
            hostname: "localhost",
            username: "root",
            db: "TriviaCrusader",
            password: "",
        });

        await db.execute("CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, username TEXT, password TEXT)");

        return new MariaDb(db);
    }

    public async createUser(id: string, username: string, password: HashedPassword): Promise<null> {
        id = uuid();
        await this.connection.query("INSERT INTO users(id, username, password) VALUES(?, ?, ?)", [id, username, password.value]);
        return null;
    }

    public async userFromName(username: string): Promise<User | null> {
        const result = await this.connection.execute("SELECT * FROM users WHERE username = ?", [username]);
        if (!result.rows || result.rows.length === 0) {
            return null;
        }
        const user = result.rows[0] ?? null;
        if (!user) {
            return null;
        }
        return user as User;
    }

    public async getUserStats(username: string): Promise<Stats | null> {
        const result = await this.connection.execute("SELECT * FROM users WHERE username = ?", [username]);
        if (!result.rows || result.rows.length === 0) {
            return null;
        }
        const user = result.rows[0] ?? null;
        if (!user) {
            return null;
        }
        return user as Stats;
    }
}
