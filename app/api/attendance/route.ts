import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// Handle CORS preflight requests
export async function OPTIONS(req: Request) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      'Access-Control-Max-Age': '86400',
    },
  });
}

// UNIFIED GET - Fetch attendance records
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const date = searchParams.get("date");
    const studentId = searchParams.get("student_id");
    const classParam = searchParams.get("class");
    const startDate = searchParams.get("start_date");
    const endDate = searchParams.get("end_date");

    console.log('📥 GET Attendance Request:', { date, studentId, classParam, startDate, endDate });

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

    console.log('🔍 SQL Query:', sql);
    console.log('📊 Values:', values);

    const [rows]: any = await db.query(sql, values);

    console.log('✅ Query Result:', { count: rows.length, sample: rows[0] });

    return NextResponse.json({
      success: true,
      message: "Attendance records fetched successfully",
      count: rows.length,
      data: rows,
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ GET Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error fetching attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED POST - Save attendance records (bulk)
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { records } = body; // Array of { student_id, date, status, notes }

    console.log('💾 POST Attendance Request:', { recordCount: records?.length, records });

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json(
        { 
          success: false,
          message: "No attendance records provided" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    // Validate and prepare records
    const validRecords = [];
    for (const record of records) {
      if (!record.student_id || !record.date || !record.status) {
        console.log('⚠️ Invalid record:', record);
        continue;
      }
      validRecords.push({
        student_id: parseInt(record.student_id),
        date: record.date,
        status: record.status,
        notes: record.notes || null
      });
    }

    if (validRecords.length === 0) {
      return NextResponse.json(
        { 
          success: false,
          message: "No valid attendance records" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    console.log('✅ Valid records to save:', validRecords);

    // Use INSERT ... ON CONFLICT for PostgreSQL (upsert)
    const values: any[] = [];
    const placeholders: string[] = [];

    for (const record of validRecords) {
      placeholders.push("(?, ?, ?, ?)");
      values.push(
        record.student_id,
        record.date,
        record.status,
        record.notes
      );
    }

    const sql = `
      INSERT INTO attendance (student_id, date, status, notes)
      VALUES ${placeholders.join(", ")}
      ON CONFLICT (student_id, date)
      DO UPDATE SET
        status = EXCLUDED.status,
        notes = EXCLUDED.notes,
        updated_at = CURRENT_TIMESTAMP
    `;

    console.log('💾 Save SQL:', sql);
    console.log('📊 Save Values:', values);

    await db.query(sql, values);

    console.log('✅ Attendance saved successfully');

    // Trigger sync notification for real-time updates
    try {
      await fetch(`${process.env.VERCEL_URL || 'http://localhost:3000'}/api/attendance/sync`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'attendance_saved',
          count: validRecords.length,
          date: validRecords[0]?.date
        })
      });
    } catch (syncError) {
      console.log('⚠️ Sync notification failed:', syncError);
      // Don't fail the main request if sync notification fails
    }

    return NextResponse.json({
      success: true,
      message: `Attendance saved successfully for ${validRecords.length} students`,
      count: validRecords.length,
      data: validRecords
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ POST Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error saving attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED PUT - Update specific attendance record
export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { student_id, date, status, notes } = body;

    console.log('🔄 PUT Attendance Request:', { student_id, date, status, notes });

    if (!student_id || !date || !status) {
      return NextResponse.json(
        { 
          success: false,
          message: "Missing required fields: student_id, date, status" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    const sql = `
      UPDATE attendance 
      SET status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP
      WHERE student_id = ? AND date = ?
    `;

    const values = [status, notes || null, parseInt(student_id), date];

    console.log('🔄 Update SQL:', sql);
    console.log('📊 Update Values:', values);

    const result = await db.query(sql, values);

    console.log('✅ Attendance updated successfully');

    return NextResponse.json({
      success: true,
      message: "Attendance updated successfully",
      data: { student_id, date, status, notes }
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ PUT Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error updating attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED DELETE - Delete attendance record
export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const studentId = searchParams.get("student_id");
    const date = searchParams.get("date");

    console.log('🗑️ DELETE Attendance Request:', { studentId, date });

    if (!studentId || !date) {
      return NextResponse.json(
        { 
          success: false,
          message: "Missing required parameters: student_id, date" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    const sql = `DELETE FROM attendance WHERE student_id = ? AND date = ?`;
    const values = [parseInt(studentId), date];

    console.log('🗑️ Delete SQL:', sql);
    console.log('📊 Delete Values:', values);

    await db.query(sql, values);

    console.log('✅ Attendance deleted successfully');

    return NextResponse.json({
      success: true,
      message: "Attendance deleted successfully",
      data: { student_id: studentId, date }
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ DELETE Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error deleting attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}