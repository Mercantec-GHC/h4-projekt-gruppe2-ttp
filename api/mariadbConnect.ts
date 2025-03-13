import { Db, InputStats, OutputStats, User, uuid } from "./db.ts";
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

    await db.execute(
      "CREATE TABLE IF NOT EXISTS users (id NVARCHAR(255) PRIMARY KEY, username TEXT, password TEXT)",
    );
    await db.execute(
      "CREATE TABLE IF NOT EXISTS user_stats (user_id NVARCHAR(255), correct_answers INT, total_answers INT, wins INT, games_played INT)",
    );
    return new MariaDb(db);
  }

  public async createUser(
    username: string,
    password: HashedPassword,
  ): Promise<null> {
    const id = uuid();
    await this.connection.execute(
      "INSERT INTO users(id, username, password) VALUES(?, ?, ?)",
      [id, username, password.value],
    );
    return null;
  }

  public async userFromUsername(username: string): Promise<User | null> {
    const result = await this.connection.execute(
      "SELECT * FROM users WHERE username = ?",
      [username],
    );
    if (!result.rows || result.rows.length === 0) {
      return null;
    }
    const user = result.rows[0] ?? null;
    if (!user) {
      return null;
    }
    return user as User;
  }

  public async userStats(userId: string): Promise<OutputStats | null> {
    const result = await this.connection.execute(
      "SELECT * FROM user_stats WHERE id = ?",
      [userId],
    );
    if (!result.rows || result.rows.length === 0) {
      return null;
    }
    const user = result.rows[0] ?? null;
    if (!user) {
      return null;
    }
    return user as OutputStats;
  }

  public async saveUserStats(
    userId: string,
    stats: InputStats,
  ): Promise<null> {
    let current = await this.userStats(userId);

    if (current == null) {
      await this.connection.execute(
        "INSERT INTO user_stats(user_id, correct_answers, total_answers, wins, games_played) VALUES(?, 0, 0, 0, 0)",
        [userId],
      );
      current = {
        user_id: userId,
        total_answers: 0,
        correct_answers: 0,
        games_played: 0,
        wins: 0,
      };
    }

    await this.connection.execute(
      "UPDATE user_stats SET correct_answers = ?, total_answers = ?, wins = ?, games_played = ? WHERE user_id = ?",
      [
        current.correct_answers + stats.correct_answers,
        current.total_answers + stats.total_answers,
        current.wins + (stats.won ? 1 : 0),
        current.games_played + 1,
        current.user_id,
      ],
    );

    return null;
  }
}
