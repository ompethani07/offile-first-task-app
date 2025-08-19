import type { Config } from "drizzle-kit";

export default {
  schema: "./db/schema.ts",   // adjust path to your schema file
  out: "./drizzle",           // where drizzle migrations go
  dialect: "postgresql",      // ✅ instead of driver: "pg"
  dbCredentials: {
    url: "postgresql://mydb_byxo_user:KCtTjIs8V8wwcvGzlJxZQjrsgnUZIacV@dpg-d2hjj8be5dus738mcg1g-a.singapore-postgres.render.com/mydb_byxo?sslmode=require",
    ssl: {
        rejectUnauthorized: false, // important for Render/Postgres
      },// important for Render/Postgres // needed on Render
}
} satisfies Config;
