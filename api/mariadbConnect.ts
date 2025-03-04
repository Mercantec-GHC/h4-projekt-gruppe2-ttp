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
      "CREATE TABLE IF NOT EXISTS user_stats (username TEXT, win_ratio FLOAT, wins INT, correctness FLOAT, games_played INT, lost INT)",
    );
    return new MariaDb(db);
  }

  public async createUser(
    username: string,
    password: HashedPassword,
  ): Promise<null> {
    const id = uuid();
    console.log(password.value);
    await this.connection.execute(
      "INSERT INTO users(id, username, password) VALUES(?, ?, ?)",
      [id, username, password.value],
    );
    return null;
  }

  public async userFromName(username: string): Promise<User | null> {
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

  public async getUserStats(username: string): Promise<OutputStats | null> {
    const result = await this.connection.execute(
      "SELECT * FROM user_stats WHERE username = ?",
      [username],
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
    username: string,
    stats: InputStats,
  ): Promise<null> {
    const current = await this.getUserStats(username);
    const correctness = stats.correctanswers / stats.totalanswers;

    console.log(correctness);

    console.log(stats);
    console.log("----");
    console.log(username, stats.won, stats.correctanswers, stats.totalanswers);
    console.log("----");
    console.log(current);

    if (current == null) {
      //creates stat record for user in db with a win
      if (stats.won == true) {
        await this.connection.execute(
          "INSERT INTO user_stats(username, win_ratio, wins, correctness, games_played, lost) VALUES(?, ?, ?, ?, ?, ?)",
          [username, 1, 1, correctness, 1, 0],
        );
      }
      //creates stat record for user in db with a loss
      if (stats.won == false) {
        await this.connection.execute(
          "INSERT INTO user_stats(username, win_ratio, wins, correctness, games_played, lost) VALUES(?, ?, ?, ?, ?, ?)",
          [username, 0, 0, correctness, 1, 1],
        );
      }
      return null;
    }
    //updates stat record for user in db with a win or loss
    if (stats.won == true) {
      const winratio = (current.wins + 1) / (current.games_played + 1);
      await this.connection.execute(
        "UPDATE user_stats SET win_ratio = ?, wins = ?, correctness = ?, games_played = ?, lost = ? WHERE username = ?",
        [
          winratio,
          current.wins + 1,
          correctness,
          current.games_played + 1,
          current.lost,
          username,
        ],
      );
    } else {
      const winratio = (current.wins) / (current.games_played + 1);
      console.log(current.lost);
      await this.connection.execute(
        "UPDATE user_stats SET win_ratio = ?, wins = ?, correctness = ?, games_played = ?, lost = ? WHERE username = ?",
        [
          winratio,
          current.wins,
          correctness,
          current.games_played + 1,
          current.lost + 1,
          username,
        ],
      );
      console.log(current.lost);
    }
    return null;
  }
}
