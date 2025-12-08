import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET attendance records with filters
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const date = searchParams.get("date");
    const studentId = searchParams.get("student_id");
    const classParam = searchParams.get("class");
    const startDate = searchParams.get("start_date");
    const endDate = searchParams.get("end_date");

    let sql = `
      SELECT a.*, s.full_name, s.phone, s.class 
      FROM attendance a 
      JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `;
    const values: any[] = [];

    if (date) {
      sql += " AND a.date = ?";
      values.push(date);
    }

    if (studentId) {
      sql += " AND a.student_id = ?";
      values.push(studentId);
    }

    if (classParam) {
      sql += " AND s.class = ?";
      values.push(classParam);
    }

    if (startDate && endDate) {
      sql += " AND a.date BETWEEN ? AND ?";
      values.push(startDate, endDate);
    }

    sql += " ORDER BY a.date DESC, s.full_name ASC";

    const [rows]: any = await db.query(sql, values);

    return NextResponse.json({
      message: "Attendance records fetched successfully",
      count: rows.length,
      data: rows,
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error fetching attendance", error: error.message },
      { status: 500 }
    );
  }
}

// POST - Save attendance (bulk)
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { records } = body; // Array of { student_id, date, status, notes }

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json(
        { message: "No attendance records provided" },
        { status: 400 }
      );
    }

    // Use INSERT ... ON DUPLICATE KEY UPDATE to handle existing records
    const values: any[] = [];
    const placeholders: string[] = [];

    for (const record of records) {
      if (!record.student_id || !record.date || !record.status) {
        continue;
      }
      placeholders.push("(?, ?, ?, ?)");
      values.push(
        record.student_id,
        record.date,
        record.status,
        record.notes || null
      );
    }

    if (placeholders.length === 0) {
      return NextResponse.json(
        { message: "No valid attendance records" },
        { status: 400 }
      );
    }

    const sql = `
      INSERT INTO attendance (student_id, date, status, notes)
      VALUES ${placeholders.join(", ")}
      ON DUPLICATE KEY UPDATE
        status = VALUES(status),
        notes = VALUES(notes),
        updated_at = CURRENT_TIMESTAMP
    `;

    await db.query(sql, values);

    return NextResponse.json({
      message: `Attendance saved successfully for ${placeholders.length} students`,
      count: placeholders.length,
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error saving attendance", error: error.message },
      { status: 500 }
    );
  }
}
