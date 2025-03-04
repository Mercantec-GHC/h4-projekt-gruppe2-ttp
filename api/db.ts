import { HashedPassword } from "./hashed_password.ts";

export type User = {
    id: string;
    name: string;
    password: string;
    stats: OutputStats;
};

export type OutputStats = {
    win_ratio: number;
    wins: number;
    correctness: number;
    games_played: number;
    losses: number;
};

export type InputStats = {
    won: boolean;
    correctanswers: number;
    totalanswers: number;
};

export type Questions = {
    question: string;
    difficulty: number;
    category: string;
};

// Token creation
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
    userFromName(username: string): Promise<User | null>;
    getUserStats(username: string): Promise<OutputStats | null>;
    saveUserStats(username: string, stats: InputStats): Promise<null>
}
