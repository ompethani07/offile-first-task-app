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

authRouter.post("/signup", async (req: Request<{}, {}, SignupBody>, res: Response) => {
    try {
        const { name, email, password } = req.body;

        // Check if email exists
        const existingUser = await db
            .select()
            .from(users)
            .where(eq(users.email, email));

        if (existingUser.length > 0) {
            return res.status(400).json({ error: "User already exists" });
        }

       const hashPassword = bcrypt.hashSync(password, 10); // Hash the password
        
       const newUser = {
            name,
            email,
            password: hashPassword,
        };

        // Insert new user into the database
        const [user] = await db.insert(users).values(newUser).returning();
        if (!user) {
            return res.status(500).json({ error: "Failed to create user" });
        }

        // Generate JWT token
         const token =  jwt.sign({ id: user.id }, "password");
       res.status(201).json({
            message: "User created successfully",
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                created_at: user.created_at,
                updated_at: user.updated_at,
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});

authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
        const { email, password } = req.body;

        // Find user by email
        const [user] = await db.select().from(users).where(eq(users.email, email));

        if (!user) {
            return res.status(400).json({ error: "Invalid email or password" });
        }

       const token =  jwt.sign({ id: user.id }, "password");
        // Check password
        const isPasswordValid = bcrypt.compareSync(password, user.password);
        if (!isPasswordValid) {
            return res.status(400).json({ error: "Invalid email or password" });
        }

       res.status(200).json({
            token,
            ...user
       })

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});

authRouter.post("/tokenIsValid",async (req,res)=>{
    const token = req.header("x-auth-token");
    if(!token) return res.json(false);
    try {
        const verified = jwt.verify(token, "password");
        if(!verified) return res.json(false);

        const user = await db.select().from(users).where(eq(users.id, (verified as any).id));
        if(user.length === 0) return res.json(false);

        res.json(true);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});

authRouter.get("/",auth, async (req :AuthRequest, res) => {
    try {
        if (!req.userId) {
            return res.status(401).json({ error: "Unauthorized" });
        }
        const user = await db.select().from(users).where(eq(users.id, req.userId));
        if (user.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }
        res.json({...user[0], token: req.token });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});
export default authRouter;
