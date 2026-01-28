import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// PUT - Update student
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { full_name, phone, class: studentClass, gender, email } = await request.json();

    // Validate required fields (gender is optional, email is required)
    if (!full_name || !phone || !studentClass || !email) {
      return NextResponse.json(
        { success: false, message: 'Name, phone, class, and email are required' },
        { status: 400 }
      );
    }

    // Validate phone number format (exactly 10 digits starting with 09)
    if (!/^09\d{8}$/.test(phone)) {
      return NextResponse.json(
        { success: false, message: 'Phone number must be exactly 10 digits and start with 09' },
        { status: 400 }
      );
    }

    // Validate email format - REQUIRED and must be @gmail.com
    if (!/^[\w-\.]+@gmail\.com$/.test(email.trim())) {
      return NextResponse.json(
        { success: false, message: 'Please provide a valid @gmail.com email address' },
        { status: 400 }
      );
    }

    // Check if student exists
    const [existing]: any = await db.query('SELECT id FROM students WHERE id = ?', [id]);

    if (existing.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Student not found' },
        { status: 404 }
      );
    }

    // Check for duplicate name (excluding current student)
    const [duplicateName]: any = await db.query(
      'SELECT id, full_name FROM students WHERE full_name = ? AND id != ?',
      [full_name, id]
    );

    if (duplicateName.length > 0) {
      return NextResponse.json(
        { 
          success: false, 
          message: `Another student with name "${full_name}" already exists`,
          error: 'DUPLICATE_NAME'
        },
        { status: 409 }
      );
    }

    // Check for duplicate phone (excluding current student)
    const [duplicatePhone]: any = await db.query(
      'SELECT id, full_name, phone FROM students WHERE phone = ? AND id != ?',
      [phone, id]
    );

    if (duplicatePhone.length > 0) {
      return NextResponse.json(
        { 
          success: false, 
          message: `Another student with phone "${phone}" already exists (${duplicatePhone[0].full_name})`,
          error: 'DUPLICATE_PHONE'
        },
        { status: 409 }
      );
    }

    // Update student (use 'Male' as default if gender is empty)
    const finalGender = gender && gender.trim() ? gender.trim() : 'Male';
    const finalEmail = email.trim();
    
    await db.query(
      'UPDATE students SET full_name = ?, phone = ?, class = ?, gender = ?, email = ? WHERE id = ?',
      [full_name, phone, studentClass, finalGender, finalEmail, id]
    );

    return NextResponse.json({
      success: true,
      message: 'Student updated successfully',
      data: {
        id: parseInt(id),
        full_name,
        phone,
        class: studentClass,
        gender: finalGender,
        email: finalEmail
      }
    });
  } catch (error: any) {
    console.error('Update student error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to update student' },
      { status: 500 }
    );
  }
}

// DELETE student
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    // Check if student exists
    const [existing]: any = await db.query('SELECT id FROM students WHERE id = ?', [id]);

    if (existing.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Student not found' },
        { status: 404 }
      );
    }

    // Delete student
    await db.query('DELETE FROM students WHERE id = ?', [id]);

    return NextResponse.json({
      success: true,
      message: 'Student deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete student error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to delete student' },
      { status: 500 }
    );
  }
}