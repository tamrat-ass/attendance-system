// import { NextResponse } from "next/server";
// import { db } from "../../../lib/db";

// export async function GET() {
//   try {
//     const [rows] = await db.query("SELECT 1 + 1 AS result");
//     return NextResponse.json({
//       message: "DB Connected!",
//       result: rows
//     });
//   } catch (error) {
//     console.error(error);
//     return NextResponse.json(
//       { message: "DB Error", error: String(error) },
//       { status: 500 }
//     );
//   }
// }
import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET() {
  const [rows] = await db.query("SELECT id, full_name FROM students LIMIT 5");
  return NextResponse.json({ rows });
}
