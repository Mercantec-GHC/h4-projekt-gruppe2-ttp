import { HashedPassword } from "./hashed_password.ts";

export type User = {
    id: string;
    name: string;
    password: string;
    stats: Stats;
};

export type Stats = {
    winratio: number;
    wins: number;
    correctness: number;
    gamesplayed: number;
    lost: number;
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
    createUser(uuid: string, username: string, password: HashedPassword): Promise<null>;
    userFromName(username: string): Promise<User | null>;
    getUserStats(username: string): Promise<Stats | null>;
}
