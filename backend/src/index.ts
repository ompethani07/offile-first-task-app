import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/task";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json()); 
app.use(express.urlencoded({ extended: true }));
app.use("/auth", authRouter);
app.use("/task", taskRouter);

app.get("/", (req, res) => {
    res.send("this is slash page !!!!!!");
});

app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
});
