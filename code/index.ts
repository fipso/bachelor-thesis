import fs from "fs";
import https from "https";
import express, { type Request, type Response } from "express";
import cookieParser from "cookie-parser";
import { trackClientHellos } from "read-tls-client-hello";

// Types
type User = {
  name: string;
  username: string;
  password: string;
  ccn: string;
};

// Hardcoded users
const users: User[] = [
  {
    name: "John Doe",
    username: "john",
    password: "password",
    ccn: "1234 5678 9012 3456",
  },
];

// In-Memory session storage
const sessions: { [id: string]: User } = {};

// Setup Middlewares
const app = express();
app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

// Check ja3 fingerprint aligns with user-agent


// Handle requests
app.post("/api/login", (req: Request, res: Response) => {
  const { username, password, twoFaCode } = req.body;
  const user = users.find((user) => user.username === username);
  if (!user) {
    return res.status(401).send("User not found");
  }

  // Demo 2FA code check
  // Any 6 digit code is accepted
  if (twoFaCode.length !== 6) {
    return res.status(401).send("2FA code incorrect");
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

  // Redirect to profile page
  res.redirect("/profile.html");
});

app.post("/api/logout", (req: Request, res: Response) => {
  const sessionId = req.cookies.sessionId;
  delete sessions[sessionId];
  res.clearCookie("sessionId");
  res.redirect("/index.html");
});

app.get("/api/profile", (req: Request, res: Response) => {
  const sessionId = req.cookies.sessionId;
  const user = sessions[sessionId];
  if (!user) {
    return res.status(401).json({ error: "Not logged in" });
  }

  res.json(user);
});

// Create HTTPS (TLS) server
const server = https.createServer(
  {
    key: fs.readFileSync(`./keys/key.pem`, "utf8"),
    cert: fs.readFileSync(`./keys/cert.pem`, "utf8"),
  },
  app,
);
// Attach TLS fingerprinting to all sockets
trackClientHellos(server);
// Start listening
server.listen(8443, () => console.log("SSL/TLS Server listening on :8443"));

// Handle server errors
// server.on("tlsClientError", (err) => console.error(err));
// server.on("error", (err) => console.error(err));
