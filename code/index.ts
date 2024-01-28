import express, { type Request, type Response } from "express";
import cookieParser from "cookie-parser";

// Types
type User = {
  name: string;
  username: string;
  password: string;
};

// Hardcoded users
const users: User[] = [
  {
    name: "John",
    username: "john",
    password: "password",
  },
];

// In-Memory session storage
const sessions: { [id: string]: User } = {};

// Setup Middlewares
const app = express();
app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

// Handle requests
app.post("/api/login", (req: Request, res: Response) => {
  const { username, password } = req.body;
  const user = users.find((user) => user.username === username);
  if (!user) {
    return res.status(401).send("User not found");
  }

  if (user.password !== password) {
    return res.status(401).send("Password incorrect");
  }

  // Create session
  const sessionId = Math.random().toString(36).substring(2, 15);
  sessions[sessionId] = user;

  // Set session cookie
  res.cookie("sessionId", sessionId, {
    httpOnly: true,
    secure: true,
    sameSite: "strict",
  });

  // Redirect to profile
  res.redirect("/profile");
});

app.get("/api/profile", (req: Request, res: Response) => {
  const sessionId = req.cookies.sessionId;
  const user = sessions[sessionId];
  if (!user) {
    return res.status(401).json({ error: "Not logged in" });
  }

  res.json(user);
});

// Start server
app.listen(8080, () => console.log("Server started on port 8080"));
