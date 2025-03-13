import { Db, Stats, User, uuid } from "./db.ts";
import { HashedPassword } from "./hashed_password.ts";

export class MemDb implements Db {
  private users: User[] = [];

  async createUser(username: string, password: HashedPassword): Promise<null> {
    await Promise.resolve();
    this.users.push({
      id: uuid(),
      username,
      password: password.value,
      stats: null,
    });
    return null;
  }
  async userFromUsername(username: string): Promise<User | null> {
    await Promise.resolve();
    return this.users.find((v) => v.username === username) ?? null;
  }
  async user(userId: string): Promise<User | null> {
    await Promise.resolve();
    return this.users.find((v) => v.id === userId) ?? null;
  }
  async userStats(userId: string): Promise<Stats | null> {
    await Promise.resolve();
    return this.users.find((v) => v.id === userId)?.stats ?? null;
  }
  async upsertGame(userId: string, stats: Stats): Promise<null> {
    await Promise.resolve();
    const user = this.users.find((v) => v.id === userId);
    if (!user) {
      return null;
    }
    user.stats = stats;
    return null;
  }
}
