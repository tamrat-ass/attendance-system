import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET - Get attendance history for a specific student
export async function GET(req: Request, { params }: { params: { id: string } }) {
  try {
    const studentId = params.id;
    const { searchParams } = new URL(req.url);
    const startDate = searchParams.get("start_date");
    const endDate = searchParams.get("end_date");
    const limit = searchParams.get("limit") || "50";

    console.log('📊 Get Student Attendance:', { studentId, startDate, endDate, limit });

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
      WHERE a.student_id = ?
    `;
    const studentIdNum = parseInt(studentId);
    if (isNaN(studentIdNum)) {
      return NextResponse.json(
        { 
          success: false,
          message: "Invalid student ID" 
        },
        { status: 400 }
      );
    }
    
    const values: any[] = [studentIdNum];

    if (startDate && endDate) {
      sql += " AND a.date BETWEEN ? AND ?";
      values.push(startDate, endDate);
    } else if (startDate) {
      sql += " AND a.date >= ?";
      values.push(startDate);
    } else if (endDate) {
      sql += " AND a.date <= ?";
      values.push(endDate);
    }

    sql += " ORDER BY a.date DESC";
    
    if (limit && !isNaN(parseInt(limit))) {
      sql += " LIMIT ?";
      values.push(parseInt(limit));
    }

    console.log('🔍 SQL Query:', sql);
    console.log('📊 Values:', values);

    const [rows]: any = await db.query(sql, values);

    // Calculate attendance statistics
    const stats = {
      total: rows.length,
      present: rows.filter(r => r.status === 'present').length,
      absent: rows.filter(r => r.status === 'absent').length,
      late: rows.filter(r => r.status === 'late').length,
      permission: rows.filter(r => r.status === 'permission').length,
    };

    stats.attendance_rate = stats.total > 0 ? 
      Math.round(((stats.present + stats.late) / stats.total) * 100) : 0;

    console.log('✅ Student Attendance Retrieved:', { count: rows.length, stats });

    return NextResponse.json({
      success: true,
      message: "Student attendance history retrieved successfully",
      student_id: studentId,
      count: rows.length,
      statistics: stats,
      data: rows,
    });
  } catch (error: any) {
    console.error('❌ Get Student Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error retrieving student attendance", 
        error: error.message 
      },
      { status: 500 }
    );
  }
}