import { Db, InputStats, Stats, User, uuid } from "./db.ts";
import { HashedPassword } from "./hashed_password.ts";
import {
  Client,
  ExecuteResult,
} from "https://deno.land/x/mysql@v2.12.1/mod.ts";

type DbUser = {
  id: string;
  username: string;
  password: string;
};

type DbStats = {
  user_id: string;
  correct_answers: number;
  total_answers: number;
  wins: number;
  games_played: number;
};

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

  private extractFirstRow<T>(result: ExecuteResult): T | null {
    if (!result.rows || result.rows.length === 0) {
      return null;
    }
    const row = result.rows[0] ?? null;
    if (!row) {
      return null;
    }
    return row as T;
  }

  public async userFromUsername(username: string): Promise<User | null> {
    const result = await this.connection.execute(
      "SELECT * FROM users WHERE username = ?",
      [username],
    );
    const user = this.extractFirstRow<DbUser>(result);
    if (user == null) {
      return null;
    }
    const stats = await this.userStats(user.id);
    return {
      id: user.id,
      username: user.username,
      password: user.password,
      stats,
    };
  }

  public async user(userId: string): Promise<User | null> {
    const result = await this.connection.execute(
      "SELECT * FROM users WHERE id = ?",
      [userId],
    );
    return this.extractFirstRow(result);
  }

  public async userStats(userId: string): Promise<Stats | null> {
    const result = await this.connection.execute(
      "SELECT * FROM user_stats WHERE id = ?",
      [userId],
    );
    const stats = this.extractFirstRow<DbStats>(result);
    return stats;
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
        userId,
      ],
    );

    return null;
  }
}
