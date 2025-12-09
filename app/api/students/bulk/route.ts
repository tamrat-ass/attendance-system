import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function POST(request: NextRequest) {
  try {
    const { students } = await request.json();

    console.log('=== BULK UPLOAD START ===');
    console.log('Number of students to upload:', students?.length);

    if (!students || !Array.isArray(students) || students.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Invalid student data' },
        { status: 400 }
      );
    }

    // Validate all students
    for (let i = 0; i < students.length; i++) {
      const student = students[i];
      if (!student.full_name || !student.phone || !student.gender || !student.class) {
        return NextResponse.json(
          { success: false, message: 'All students must have full_name, phone, gender, and class' },
          { status: 400 }
        );
      }

      // Validate phone number format (exactly 10 digits starting with 09)
      if (!/^09\d{8}$/.test(student.phone)) {
        return NextResponse.json(
          { success: false, message: `Row ${i + 1}: Phone number "${student.phone}" must be exactly 10 digits and start with 09` },
          { status: 400 }
        );
      }
      
      // Validate gender
      if (!['Male', 'Female'].includes(student.gender)) {
        return NextResponse.json(
          { success: false, message: `Row ${i + 1}: Gender must be either "Male" or "Female"` },
          { status: 400 }
        );
      }
    }

    const connection = await db.getConnection();
    
    try {
      // Check existing students count BEFORE upload
      const [beforeCount]: any = await connection.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database BEFORE upload:', beforeCount[0].count);

      // Get all existing students to check for duplicates
      const [existingStudents]: any = await connection.query(
        'SELECT full_name, phone FROM students'
      );

      console.log('Total existing students in database:', existingStudents.length);

      // Create a Set of existing student identifiers (name + phone combination)
      const existingSet = new Set(
        existingStudents.map((s: any) => `${s.full_name.toLowerCase().trim()}|${s.phone.trim()}`)
      );

      console.log('Existing student identifiers:', Array.from(existingSet).slice(0, 5), '...');

      await connection.beginTransaction();

      const insertedStudents = [];
      const skippedStudents = [];
      
      for (const student of students) {
        const identifier = `${student.full_name.toLowerCase().trim()}|${student.phone.trim()}`;
        
        console.log('Checking student:', student.full_name, '| Identifier:', identifier);
        console.log('Exists in database?', existingSet.has(identifier));
        
        // Check if student already exists
        if (existingSet.has(identifier)) {
          console.log('✗ SKIPPING duplicate student:', student.full_name, student.phone);
          skippedStudents.push({
            ...student,
            reason: 'Duplicate (same name and phone already exists)'
          });
          continue;
        }

        console.log('✓ INSERTING new student:', student.full_name);
        const [result] = await connection.query(
          'INSERT INTO students (full_name, phone, gender, class) VALUES (?, ?, ?, ?)',
          [student.full_name, student.phone, student.gender, student.class]
        );
        
        const newStudent = {
          id: (result as any).insertId,
          ...student
        };
        
        insertedStudents.push(newStudent);
        // Add to existing set to prevent duplicates within the same upload
        existingSet.add(identifier);
      }

      await connection.commit();

      // Check existing students count AFTER upload
      const [afterCount]: any = await connection.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database AFTER upload:', afterCount[0].count);
      console.log('Inserted:', insertedStudents.length, 'Skipped:', skippedStudents.length);
      console.log('=== BULK UPLOAD COMPLETE ===');

      return NextResponse.json({
        success: true,
        message: `Successfully added ${insertedStudents.length} students${skippedStudents.length > 0 ? `, skipped ${skippedStudents.length} duplicates` : ''}`,
        data: insertedStudents,
        skipped: skippedStudents,
        summary: {
          total: students.length,
          inserted: insertedStudents.length,
          skipped: skippedStudents.length
        }
      });
    } catch (error: any) {
      await connection.rollback();
      console.error('Transaction rolled back due to error');
      throw error;
    } finally {
      connection.release();
    }
  } catch (error: any) {
    console.error('Bulk upload error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to upload students' },
      { status: 500 }
    );
  }
}
