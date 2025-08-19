import { Request, Response, Router } from "express";
import { db } from "../db";
import { eq } from "drizzle-orm";
import { users } from "../db/schema";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../midleware/auth";

const authRouter = Router();

interface SignupBody {
  name: string;
  email: string;
  password: string;
}

interface LoginBody {
  email: string;
  password: string;
}

const JWT_SECRET = process.env.JWT_SECRET || "password";

// ✅ SIGNUP
authRouter.post("/signup", async (req: Request<{}, {}, SignupBody>, res: Response) => {
  try {
    const { name, email, password } = req.body;

    // Check if email exists
    const existingUser = await db.select().from(users).where(eq(users.email, email));
    if (existingUser.length > 0) {
      return res.status(400).json({ error: "User already exists" });
    }

    // Hash password
    const hashPassword = bcrypt.hashSync(password, 10);

    // Insert new user
    const [user] = await db.insert(users).values({
      name,
      email,
      password: hashPassword,
    }).returning();

    if (!user) {
      return res.status(500).json({ error: "Failed to create user" });
    }

    // Generate JWT
    const token = jwt.sign({ id: user.id }, JWT_SECRET);

    // Don’t send hashed password in response
    const { password: _, ...userWithoutPassword } = user;

    res.status(201).json({
      token,
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// ✅ LOGIN
authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const [user] = await db.select().from(users).where(eq(users.email, email));
    if (!user) {
      return res.status(400).json({ error: "Invalid email or password" });
    }

    // Validate password
    const isPasswordValid = bcrypt.compareSync(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ error: "Invalid email or password" });
    }

    // Generate JWT
    const token = jwt.sign({ id: user.id }, JWT_SECRET);

    // Don’t send hashed password in response
    const { password: _, ...userWithoutPassword } = user;

    res.status(200).json({
      token,
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// ✅ TOKEN VALIDATION
authRouter.post("/tokenIsValid", async (req, res) => {
  const token = req.header("x-auth-token");
  if (!token) return res.json(false);

  try {
    const verified = jwt.verify(token, JWT_SECRET) as { id: string };
    if (!verified) return res.json(false);

    const user = await db.select().from(users).where(eq(users.id, verified.id));
    if (user.length === 0) return res.json(false);

    res.json(true);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// ✅ GET USER PROFILE (Protected Route)
authRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const user = await db.select().from(users).where(eq(users.id, req.userId));
    if (user.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Don’t send password in response
    const { password: _, ...userWithoutPassword } = user[0];

    res.json({
      ...userWithoutPassword,
      token: req.token,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

export default authRouter;
