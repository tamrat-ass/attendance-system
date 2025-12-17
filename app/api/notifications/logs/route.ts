import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const limit = Number(searchParams.get("limit")) || 50;
    const offset = Number(searchParams.get("offset")) || 0;
    const type = searchParams.get("type"); // 'registration' or 'bulk'

    let sql = `
      SELECT 
        el.*,
        s.full_name as student_name,
        s.class as student_class
      FROM email_logs el
      LEFT JOIN students s ON el.student_id = s.id
    `;
    
    const conditions: string[] = [];
    const values: any[] = [];

    if (type) {
      conditions.push("el.type = ?");
      values.push(type);
    }

    if (conditions.length > 0) {
      sql += " WHERE " + conditions.join(" AND ");
    }

    sql += " ORDER BY el.timestamp DESC LIMIT ? OFFSET ?";
    values.push(limit, offset);

    const [logs]: any = await db.query(sql, values);

    // Format the logs for frontend consumption
    const formattedLogs = logs.map((log: any) => ({
      id: log.id,
      type: log.type,
      recipient: log.recipient,
      sender: log.sender,
      content: log.content,
      status: log.status,
      error_message: log.error_message,
      student_id: log.student_id,
      student_name: log.student_name,
      student_class: log.student_class,
      timestamp: log.timestamp,
    }));

    return NextResponse.json({
      message: "Email logs fetched successfully",
      logs: formattedLogs,
      count: logs.length,
    });

  } catch (error: any) {
    console.error('Email logs error:', error);
    return NextResponse.json(
      { message: "Error fetching email logs", error: error.message },
      { status: 500 }
    );
  }
}