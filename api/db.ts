import { HashedPassword } from "./hashed_password.ts";

export type User = {
  id: string;
  username: string;
  password: string;
};

export type OutputStats = {
  win_ratio: number;
  wins: number;
  correctness: number;
  games_played: number;
  lost: number;
};

export type InputStats = {
  won: boolean;
  correct_answers: number;
  total_answers: number;
};

export type Questions = {
  question: string;
  difficulty: number;
  category: string;
};

export function uuid() {
  const id = crypto.randomUUID();
  return id;
}

export type Token = {
  user: User["id"];
  value: string;
};

export function token(user: User["id"]): Token {
  return {
    user,
    value: uuid(),
  };
}

export interface Db {
  createUser(username: string, password: HashedPassword): Promise<null>;
  user(userId: string): Promise<User | null>;
  userStats(userId: string): Promise<OutputStats | null>;
  saveUserStats(userId: string, stats: InputStats): Promise<null>;
}
