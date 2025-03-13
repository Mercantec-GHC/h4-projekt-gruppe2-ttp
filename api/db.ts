import { HashedPassword } from "./hashed_password.ts";

export type User = {
  id: string;
  username: string;
  password: string;
};

export type OutputStats = {
  user_id: string;
  correct_answers: number;
  total_answers: number;
  wins: number;
  games_played: number;
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
  userFromUsername(username: string): Promise<User | null>;
  userStats(userId: string): Promise<OutputStats | null>;
  saveUserStats(userId: string, stats: InputStats): Promise<null>;
}
