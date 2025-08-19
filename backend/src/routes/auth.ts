import { Request, Response, Router } from "express";
import { db } from "../db";
import { eq } from "drizzle-orm";
import { users } from "../db/schema";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../midleware/auth";

const authRouter = Router();
const JWT_SECRET = process.env.JWT_SECRET || "password";

interface SignupBody {
  name: string;
  email: string;
  password: string;
}
interface LoginBody {
  email: string;
  password: string;
}

// Signup route
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

    // Insert user
    const [user] = await db.insert(users).values({
      name,
      email,
      password: hashPassword,
    }).returning();

    if (!user) {
      return res.status(500).json({ error: "Failed to create user" });
    }

    // Generate token
    const token = jwt.sign({ id: user.id }, JWT_SECRET);

    // Remove password from response
    const safeUser = { ...user };
    delete (safeUser as any).password;

    res.status(201).json({ token, user: safeUser });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// Login route
authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
  try {
    const { email, password } = req.body;

    const [user] = await db.select().from(users).where(eq(users.email, email));
    if (!user) {
      return res.status(400).json({ error: "Invalid email or password" });
    }

    const isPasswordValid = bcrypt.compareSync(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ error: "Invalid email or password" });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET);

    const safeUser = { ...user };
    delete (safeUser as any).password;

    res.status(200).json({ token, user: safeUser });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// Token validation route
authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);

    const verified = jwt.verify(token, JWT_SECRET);
    if (!verified) return res.json(false);

    const user = await db.select().from(users).where(eq(users.id, (verified as any).id));
    if (user.length === 0) return res.json(false);

    res.json(true);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

// Get current user
authRouter.get("/", auth, async (req: AuthRequest, res: Response) => {
  try {
    if (!req.userId) return res.status(401).json({ error: "Unauthorized" });

    const [user] = await db.select().from(users).where(eq(users.id, req.userId));
    if (!user) return res.status(404).json({ error: "User not found" });

    const safeUser = { ...user };
    delete (safeUser as any).password;

    res.json({ ...safeUser, token: req.token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: String(error) });
  }
});

export default authRouter;
