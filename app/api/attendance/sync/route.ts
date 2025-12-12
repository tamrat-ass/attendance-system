import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET - Check for recent attendance updates (for polling)
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const since = searchParams.get("since"); // timestamp
    
    let sql = `
      SELECT COUNT(*) as count, MAX(created_at) as last_update
      FROM attendance 
      WHERE 1=1
    `;
    const values: any[] = [];

    if (since) {
      sql += " AND created_at > ?";
      values.push(since);
    }

    const [rows]: any = await db.query(sql, values);
    const result = rows[0];

    return NextResponse.json({
      message: "Sync check completed",
      hasUpdates: result.count > 0,
      lastUpdate: result.last_update,
      count: result.count,
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error checking sync", error: error.message },
      { status: 500 }
    );
  }
}

// POST - Trigger sync notification (called after attendance save)
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { action, count, date } = body;

    // This could be extended to use WebSockets or Server-Sent Events
    // For now, just return success to indicate sync trigger
    
    return NextResponse.json({
      message: `Sync notification sent: ${action}`,
      timestamp: new Date().toISOString(),
      data: { count, date }
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error triggering sync", error: error.message },
      { status: 500 }
    );
  }
}