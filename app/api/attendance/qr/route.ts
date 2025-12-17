import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import crypto from "crypto";

// Mark attendance via QR code scan
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { qr_data, date, notes } = body;

    if (!qr_data) {
      return NextResponse.json(
        { message: "QR data is required" },
        { status: 400 }
      );
    }

    // Parse QR data
    let qrInfo;
    try {
      qrInfo = JSON.parse(qr_data);
    } catch (e) {
      return NextResponse.json(
        { message: "Invalid QR code format" },
        { status: 400 }
      );
    }

    const { student_id, full_name, phone, token } = qrInfo;

    if (!student_id || !full_name || !phone || !token) {
      return NextResponse.json(
        { message: "Invalid QR code data" },
        { status: 400 }
      );
    }

    // Validate QR token
    const expectedToken = generateQRToken(student_id, full_name, phone);
    if (token !== expectedToken) {
      return NextResponse.json(
        { message: "Invalid or tampered QR code" },
        { status: 401 }
      );
    }

    // Verify student exists in database
    const [students]: any = await db.query(
      "SELECT id, full_name, class FROM students WHERE id = ? AND full_name = ? AND phone = ?",
      [student_id, full_name, phone]
    );

    if (students.length === 0) {
      return NextResponse.json(
        { message: "Student not found or QR code mismatch" },
        { status: 404 }
      );
    }

    const student = students[0];
    const attendanceDate = date || getCurrentEthiopianDate();

    // Check if attendance already marked for today
    const [existingAttendance]: any = await db.query(
      "SELECT id, status FROM attendance WHERE student_id = ? AND date = ?",
      [student_id, attendanceDate]
    );

    if (existingAttendance.length > 0) {
      return NextResponse.json(
        { 
          message: "Attendance already marked for today",
          current_status: existingAttendance[0].status,
          student_name: student.full_name,
          student_class: student.class
        },
        { status: 409 }
      );
    }

    // Mark attendance as present
    await db.query(
      "INSERT INTO attendance (student_id, date, status, notes) VALUES (?, ?, ?, ?)",
      [student_id, attendanceDate, 'present', notes || 'Marked via QR scan']
    );

    // Log the QR attendance action
    try {
      await db.query(
        "INSERT INTO qr_attendance_logs (student_id, qr_data, scan_timestamp, status) VALUES (?, ?, NOW(), ?)",
        [student_id, qr_data, 'success']
      );
    } catch (logError) {
      console.error('Failed to log QR attendance:', logError);
      // Don't fail the attendance marking if logging fails
    }

    return NextResponse.json({
      message: "Attendance marked successfully",
      student_id: student_id,
      student_name: student.full_name,
      student_class: student.class,
      attendance_status: 'present',
      date: attendanceDate,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('QR attendance error:', error);
    return NextResponse.json(
      { message: "Error processing QR attendance", error: error.message },
      { status: 500 }
    );
  }
}

// Validate QR code without marking attendance
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const qrData = searchParams.get("qr_data");

    if (!qrData) {
      return NextResponse.json(
        { message: "QR data is required" },
        { status: 400 }
      );
    }

    // Parse QR data
    let qrInfo;
    try {
      qrInfo = JSON.parse(qrData);
    } catch (e) {
      return NextResponse.json(
        { message: "Invalid QR code format" },
        { status: 400 }
      );
    }

    const { student_id, full_name, phone, token } = qrInfo;

    if (!student_id || !full_name || !phone || !token) {
      return NextResponse.json(
        { message: "Invalid QR code data" },
        { status: 400 }
      );
    }

    // Validate QR token
    const expectedToken = generateQRToken(student_id, full_name, phone);
    if (token !== expectedToken) {
      return NextResponse.json(
        { 
          valid: false,
          message: "Invalid or tampered QR code" 
        }
      );
    }

    // Verify student exists
    const [students]: any = await db.query(
      "SELECT id, full_name, class FROM students WHERE id = ? AND full_name = ? AND phone = ?",
      [student_id, full_name, phone]
    );

    if (students.length === 0) {
      return NextResponse.json(
        { 
          valid: false,
          message: "Student not found" 
        }
      );
    }

    const student = students[0];

    return NextResponse.json({
      valid: true,
      message: "Valid student QR code",
      student_id: student.id,
      student_name: student.full_name,
      student_class: student.class
    });

  } catch (error: any) {
    console.error('QR validation error:', error);
    return NextResponse.json(
      { message: "Error validating QR code", error: error.message },
      { status: 500 }
    );
  }
}

// Helper function to generate QR token (same as in Flutter)
function generateQRToken(studentId: number, fullName: string, phone: string): string {
  const data = `${studentId}_${fullName}_${phone}_mk_attendance`;
  return crypto.createHash('sha256').update(data).digest('hex').substring(0, 16);
}

// Add the missing QR token generation function to registration API
function addQRTokenToRegistrationEmail() {
  // This function should be called when sending registration emails
  // to include QR code information in the email
}

// Helper function to get current Ethiopian date
function getCurrentEthiopianDate(): string {
  // This should match your Ethiopian date conversion logic
  // For now, using a simple format - you should implement proper Ethiopian calendar conversion
  const now = new Date();
  const year = now.getFullYear() - 7; // Approximate Ethiopian year
  const month = (now.getMonth() + 1).toString().padStart(2, '0');
  const day = now.getDate().toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}