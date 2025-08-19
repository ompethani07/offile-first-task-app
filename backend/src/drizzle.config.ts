import type { Config } from "drizzle-kit";

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) throw new Error("DATABASE_URL is not set");

export default {
  schema: "./db/schema.ts",   // path to your schema file
  out: "./drizzle",           // where drizzle migrations go
  dialect: "postgresql",
  dbCredentials: {
    url: DATABASE_URL, // ensure SSL for Render
  },
} satisfies Config;
