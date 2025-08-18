import { Router } from "express";
import { auth, AuthRequest } from "../midleware/auth";
import { NewTask, tasks } from "../db/schema";
import { db } from "../db";
import { eq } from "drizzle-orm";

const taskRouter = Router();

taskRouter.post("/", auth,async(req:AuthRequest, res) => {
try {
    if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
    }
    console.log("Received request body:", req.body);
    req.body = {...req.body ,dueDate : new Date(req.body.dueDate),userId : req.userId} // Set the userId from the authenticated user
    const newTask : NewTask = req.body;
    console.log("New task to be inserted:", newTask);
    const task = await db.insert(tasks).values(newTask).returning();
    console.log("Task after insertion:", task[0]);
    if (task.length === 0) {
        return res.status(400).json({ message: "Failed to create task" });
    }
    res.status(201).json(task[0]);
    // res.json(task);
} catch (error) {
    console.error("Error in taskRouter POST:", error);
    res.status(500).json({ message: "Internal server error" });   
}
});


taskRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
       const alltasks =  await db.select().from(tasks).where(eq(tasks.userId, req.userId!));
        res.json(alltasks);
        res.status(200).json(alltasks);
    } catch (error) {
        console.error("Error in taskRouter GET:", error);
        res.status(500).json({ message: "Internal server error" });
    }
});

taskRouter.delete("/", auth, async (req: AuthRequest, res) => {
    try {
        const {taskId} : {taskId : string} = req.body;
        const deletedTask = await db.delete(tasks).where(eq(tasks.id, taskId!)).returning();
        if (deletedTask.length === 0) {
            return res.status(404).json({ message: "Task not found" });
        }
        res.json({ message: "Task deleted successfully", task: deletedTask[0] });
    } catch (error) {
        console.error("Error in taskRouter DELETE:", error);
        res.status(500).json({ message: "Internal server error" });
    }
});
    
taskRouter.post("/sync", auth,async(req:AuthRequest, res) => {
try {
    if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
    }
    console.log("Received request body:", req.body);

    const filterTasks : NewTask[] = [];
    
    const taskList = req.body;
    for(let t of taskList){
        t= {...t,dueDate:new Date(t.dueDate),createdAt:new Date(t.createdAt),updatedAt:new Date(t.updatedAt),userId:req.userId}
        filterTasks.push(t);
    }
    // console.log("New task to be inserted:", newTask);
    const pushedTaksToDatabase = await db.insert(tasks).values(filterTasks).returning();
    // console.log("Task after insertion:", task[0]);
    // if (task.length === 0) {
    //     return res.status(400).json({ message: "Failed to create task" });
    // }
    res.status(201).json(pushedTaksToDatabase);
    console.log(taskList);
    // res.json(task);
} catch (error) {
    console.error("Error in taskRouter POST:", error);
    res.status(500).json({ message: "Internal server error" });   
}
});








export  default taskRouter;