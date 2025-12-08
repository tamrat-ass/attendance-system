import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// PUT - Update student
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { full_name, phone, class: studentClass } = await request.json();

    // Validate required fields
    if (!full_name || !phone || !studentClass) {
      return NextResponse.json(
        { success: false, message: 'All fields are required' },
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

    // Check if student exists
    const [existing]: any = await db.query('SELECT id FROM students WHERE id = ?', [id]);

    if (existing.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Student not found' },
        { status: 404 }
      );
    }

    // Update student
    await db.query(
      'UPDATE students SET full_name = ?, phone = ?, class = ? WHERE id = ?',
      [full_name, phone, studentClass, id]
    );

    return NextResponse.json({
      success: true,
      message: 'Student updated successfully',
      data: {
        id: parseInt(id),
        full_name,
        phone,
        class: studentClass
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