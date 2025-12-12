import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET - Get all attendance for a specific date
export async function GET(req: Request, { params }: { params: { date: string } }) {
  try {
    const date = params.date;
    const { searchParams } = new URL(req.url);
    const className = searchParams.get("class");

    console.log('📅 Get Date Attendance:', { date, className });

    let sql = `
      SELECT 
        a.id,
        a.student_id,
        a.date,
        a.status,
        a.notes,
        a.created_at,
        a.updated_at,
        s.full_name as student_name,
        s.phone,
        s.class as class_name
      FROM attendance a 
      JOIN students s ON a.student_id = s.id
      WHERE a.date = ?
    `;
    const values: any[] = [date];

    if (className) {
      sql += " AND s.class = ?";
      values.push(className);
    }

    sql += " ORDER BY s.class, s.full_name";

    console.log('🔍 SQL Query:', sql);
    console.log('📊 Values:', values);

    const [rows]: any = await db.query(sql, values);

    // Calculate daily statistics
    const stats = {
      total: rows.length,
      present: rows.filter(r => r.status === 'present').length,
      absent: rows.filter(r => r.status === 'absent').length,
      late: rows.filter(r => r.status === 'late').length,
      permission: rows.filter(r => r.status === 'permission').length,
    };

    stats.attendance_rate = stats.total > 0 ? 
      Math.round(((stats.present + stats.late) / stats.total) * 100) : 0;

    // Group by class
    const byClass = {};
    rows.forEach(row => {
      if (!byClass[row.class_name]) {
        byClass[row.class_name] = [];
      }
      byClass[row.class_name].push(row);
    });

    console.log('✅ Date Attendance Retrieved:', { date, count: rows.length, stats });

    return NextResponse.json({
      success: true,
      message: "Date attendance retrieved successfully",
      date: date,
      count: rows.length,
      statistics: stats,
      by_class: byClass,
      data: rows,
    });
  } catch (error: any) {
    console.error('❌ Get Date Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error retrieving date attendance", 
        error: error.message 
      },
      { status: 500 }
    );
  }
}