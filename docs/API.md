## API Spec

## Endpoints

### POST /createUser

**Request**

```ts
username: string,
passowrd: string,
```

**Response**

```ts
Messages: "Success" | "User alreay exists" | "Please fill out all fields";
```

### POST /login

**Request**

```ts
username: string,
password: string,
```

**Response**

```ts
Messages: "Success" + JWT Cookie | "Please fill out all required fields." | "No user found." | "Incorrect password.";
```

### POST /DeleteUser

Should it only be the user themselves that can delete their account?

**Request**

```ts
username: string,
token: Token,
```

**Response**

```ts
Messages: "Success" | "Couldn't find a user with that name" | "fejl 500";
```

### GET /userStats

**Request**

```ts
username: string;
```

**Response**

```ts

```

### GET /Question

**Request**

```ts
difficulty: int,
category:
```

**Response**

```ts

```

### saveGamendgametodatabaseefterslut
