authRouter.post("/signup", async (req: Request<{}, {}, SignupBody>, res: Response) => {
    try {
        const { name, email, password } = req.body;

        const existingUser = await db.select().from(users).where(eq(users.email, email));
        if (existingUser.length > 0) {
            return res.status(400).json({ error: "User already exists" });
        }

        const hashPassword = bcrypt.hashSync(password, 10);

        const [user] = await db.insert(users).values({
            name,
            email,
            password: hashPassword,
        }).returning();

        if (!user) {
            return res.status(500).json({ error: "Failed to create user" });
        }

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || "password");

        res.status(201).json({
            token,
            ...user,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});

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

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || "password");

        res.status(200).json({
            token,
            ...user,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: String(error) });
    }
});
