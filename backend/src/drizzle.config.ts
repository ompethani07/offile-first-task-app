import type { Config } from "drizzle-kit";

export default {
  schema: "./db/schema.ts",   // adjust path to your schema file
  out: "./drizzle",           // where drizzle migrations go
  dialect: "postgresql",      // ✅ instead of driver: "pg"
  dbCredentials: {
    url: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false, // important for Render/Postgres
      },// important for Render/Postgres // needed on Render
}
} satisfies Config;
