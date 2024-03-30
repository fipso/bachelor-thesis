import fs from "fs";
import https from "https";
import express, { type Request, type Response } from "express";
import cookieParser from "cookie-parser";
import { trackClientHellosJA3N } from "./fingerprint";

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

// Check ja3 fingerprint aligns with user-agent
/*
app.use((req, res, next) => {
  //@ts-ignore
  const ja3 = req.socket.tlsClientHello?.ja3;
  //@ts-ignore
  const ja3n = req.socket.tlsClientHello?.ja3n;
  const userAgent = req.headers["user-agent"];
  console.log("JA3:", ja3);
  console.log("JA3N:", ja3n);
  console.log("User-Agent:", userAgent);
  next();
});*/

// Serve static files
app.use(express.static("public"));

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
trackClientHellosJA3N(server);

// Start listening
server.listen(8443, () => console.log("SSL/TLS Server listening on :8443"));

server.on('request', (request, response) => {
    // In your normal request handler, check `tlsClientHello` on the request's socket:
    // @ts-ignore
    console.log('Received request with TLS client hello:', request.socket.tlsClientHello.ja3n);
});

// Handle server errors
// server.on("tlsClientError", (err) => console.error(err));
// server.on("error", (err) => console.error(err));
