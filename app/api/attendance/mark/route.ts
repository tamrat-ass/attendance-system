import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// POST - Mark attendance for a single student (simple endpoint)
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { student_id, date, status, notes } = body;

    console.log('📝 Mark Attendance Request:', { student_id, date, status, notes });

    // Validate required fields
    if (!student_id || !date || !status) {
      return NextResponse.json(
        { 
          success: false,
          message: "Missing required fields: student_id, date, status" 
        },
        { status: 400 }
      );
    }

    // Validate status
    const validStatuses = ['present', 'absent', 'late', 'permission'];
    if (!validStatuses.includes(status)) {
      return NextResponse.json(
        { 
          success: false,
          message: `Invalid status. Must be one of: ${validStatuses.join(', ')}` 
        },
        { status: 400 }
      );
    }

    // Check if attendance already exists
    const checkSql = `SELECT id, status FROM attendance WHERE student_id = ? AND date = ?`;
    const [existingRows]: any = await db.query(checkSql, [student_id, date]);

    if (existingRows.length > 0) {
      // Update existing attendance
      const updateSql = `
        UPDATE attendance 
        SET status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP
        WHERE student_id = ? AND date = ?
      `;
      
      await db.query(updateSql, [status, notes || null, student_id, date]);
      
      console.log(`✅ Updated attendance for student ${student_id}: ${existingRows[0].status} → ${status}`);
      
      return NextResponse.json({
        success: true,
        message: "Attendance updated successfully",
        action: "updated",
        data: { student_id, date, status, notes, previous_status: existingRows[0].status }
      });
    } else {
      // Insert new attendance
      const insertSql = `
        INSERT INTO attendance (student_id, date, status, notes)
        VALUES (?, ?, ?, ?)
      `;
      
      const [result]: any = await db.query(insertSql, [student_id, date, status, notes || null]);
      
      console.log(`✅ Created new attendance for student ${student_id}: ${status}`);
      
      return NextResponse.json({
        success: true,
        message: "Attendance marked successfully",
        action: "created",
        data: { student_id, date, status, notes, id: result.insertId }
      });
    }

  } catch (error: any) {
    console.error('❌ Mark Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error marking attendance", 
        error: error.message 
      },
      { status: 500 }
    );
  }
}