import { Db, User, uuid, Stats } from "./db.ts";
import { HashedPassword } from "./hashed_password.ts";
import { Client } from "https://deno.land/x/mysql@v2.12.1/mod.ts";

export class MariaDb implements Db {
    private connection: Client;

    private constructor(client: Client) {
        this.connection = client;
    }

    public static async connect(): Promise<MariaDb> {
        const db = await new Client().connect({
            hostname: "127.0.0.1",
            username: "admin",
            db: "TriviaCrusader",
            password: "admin",
        });

        await db.execute("CREATE TABLE IF NOT EXISTS users (id NVARCHAR(255) PRIMARY KEY, username TEXT, password TEXT)");
        await db.execute("CREATE TABLE IF NOT EXISTS user_stats(username TEXT, win_ratio FLOAT, wins INT, correctness FLOAT, games_played INT, lost INT")
        return new MariaDb(db);
    }

    public async createUser(username: string, password: HashedPassword): Promise<null> {
        const id = uuid();
        console.log(password.value);
        await this.connection.execute("INSERT INTO users(id, username, password) VALUES(?, ?, ?)", [id, username, password.value]);
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
        const result = await this.connection.execute("SELECT * FROM user_stats WHERE username = ?", [username]);
        if (!result.rows || result.rows.length === 0) {
            return null;
        }
        const user = result.rows[0] ?? null;
        if (!user) {
            return null;
        }
        return user as Stats;
    }

    public async saveUserStats(username: string, stats: Stats): Promise<null> {
        const current = await this.getUserStats(username);
        if ( current == null ) {
        const result = await this.connection.execute("INSERT INTO user_stats(win_ratio, wins, correctness, games_played, lost, username) VALUES(?,?,?,?,?,?)", [stats.winratio, stats.wins, stats.correctness, stats.gamesplayed, stats.lost, username])
            
            return null;
        }
        stats.winratio = current?.wins / current?.lost; 
        stats.correctness = current.correctness * stats.correctness

        const result = await this.connection.execute("UPDATE user_stats SET win_ratio = ?, wins = ?, correctness = ?, games_played = ?, lost = ? WHERE username = ?", [stats.winratio, stats.wins, stats.correctness, stats.gamesplayed, stats.lost, username])
        return null;
    }
}
