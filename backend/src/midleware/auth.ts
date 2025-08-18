import { UUID } from "crypto";
import {NextFunction, Request , Response } from "express";
import jwt from "jsonwebtoken";
export interface AuthRequest extends Request {
    userId?: UUID;
    token?: string;
     
}

export const auth = async (req:AuthRequest, res:Response, next:NextFunction) => {
    
    const token = req.header("x-auth-token");
    if (!token) {
        return res.status(401).json({ error: "No authentication token, authorization denied" });
    }
    try {
        const verified = jwt.verify(token, "password");
        req.userId = (verified as any).id; // Assuming the token contains the user ID
        next();
    } catch (error) {
        console.error(error);
        res.status(401).json({ error: "Token is not valid" });
    }
}