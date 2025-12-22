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

    // Comprehensive validation of all students
    const validationErrors: string[] = [];
    
    for (let i = 0; i < students.length; i++) {
      const student = students[i];
      const rowNum = i + 1;
      
      // Check required fields
      if (!student.full_name || student.full_name.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing full name`);
      }
      if (!student.phone || student.phone.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing phone number`);
      }
      if (!student.class || student.class.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing class`);
      }
      
      // Validate phone number format (exactly 10 digits starting with 09)
      if (student.phone && !/^09\d{8}$/.test(student.phone.trim())) {
        validationErrors.push(`Row ${rowNum}: Invalid phone "${student.phone}" (must be 09xxxxxxxx)`);
      }
      
      // Validate gender (allow flexible input)
      if (student.gender && !['Male', 'Female', 'male', 'female', 'M', 'F', 'm', 'f'].includes(student.gender)) {
        validationErrors.push(`Row ${rowNum}: Invalid gender "${student.gender}" (must be Male or Female)`);
      }
      
      // Validate name length
      if (student.full_name && student.full_name.trim().length < 2) {
        validationErrors.push(`Row ${rowNum}: Full name too short (minimum 2 characters)`);
      }
      
      // Validate class name
      if (student.class && student.class.trim().length < 1) {
        validationErrors.push(`Row ${rowNum}: Class name too short`);
      }
    }
    
    // Return validation errors if any
    if (validationErrors.length > 0) {
      const errorMessage = `Validation failed for ${validationErrors.length} row(s):\n\n${validationErrors.slice(0, 10).join('\n')}${validationErrors.length > 10 ? `\n... and ${validationErrors.length - 10} more errors` : ''}`;
      
      return NextResponse.json(
        { 
          success: false, 
          message: errorMessage,
          errors: validationErrors,
          errorCount: validationErrors.length
        },
        { status: 400 }
      );
    }

    try {
      // Check existing students count BEFORE upload
      const [beforeCount]: any = await db.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database BEFORE upload:', beforeCount[0].count);

      // Get all existing students to check for duplicates
      const [existingStudents]: any = await db.query(
        'SELECT full_name, phone FROM students'
      );

      console.log('Total existing students in database:', existingStudents.length);

      // Create a Set of existing student identifiers (name + phone combination)
      const existingSet = new Set(
        existingStudents.map((s: any) => `${s.full_name.toLowerCase().trim()}|${s.phone.trim()}`)
      );

      console.log('Existing student identifiers:', Array.from(existingSet).slice(0, 5), '...');

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
        
        // Normalize gender value - read from student data
        let normalizedGender = 'Male'; // Default fallback
        if (student.gender) {
          const genderLower = student.gender.toLowerCase().trim();
          // Check for female variations
          if (genderLower === 'female' || genderLower === 'f' || genderLower.startsWith('fem')) {
            normalizedGender = 'Female';
          }
          // Check for male variations
          else if (genderLower === 'male' || genderLower === 'm' || genderLower.startsWith('mal')) {
            normalizedGender = 'Male';
          }
        }
        
        try {
          const [result] = await db.execute(
            'INSERT INTO students (full_name, phone, gender, class) VALUES (?, ?, ?, ?)',
            [student.full_name.trim(), student.phone.trim(), normalizedGender, student.class.trim()]
          );
          
          const newStudent = {
            id: (result as any).insertId || Date.now(), // Fallback ID for PostgreSQL
            full_name: student.full_name.trim(),
            phone: student.phone.trim(),
            gender: normalizedGender,
            class: student.class.trim()
          };
          
          insertedStudents.push(newStudent);
          // Add to existing set to prevent duplicates within the same upload
          existingSet.add(identifier);
        } catch (insertError) {
          console.error('Error inserting student:', student.full_name, insertError);
          skippedStudents.push({
            ...student,
            reason: 'Database insertion failed'
          });
        }
      }

      // Check existing students count AFTER upload
      const [afterCount]: any = await db.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database AFTER upload:', afterCount[0].count);
      console.log('Inserted:', insertedStudents.length, 'Skipped:', skippedStudents.length);
      console.log('=== BULK UPLOAD COMPLETE ===');

      return NextResponse.json({
        success: true,
        message: `Successfully processed ${students.length} students: ${insertedStudents.length} added${skippedStudents.length > 0 ? `, ${skippedStudents.length} skipped` : ''}`,
        data: insertedStudents,
        skipped: skippedStudents,
        summary: {
          total: students.length,
          inserted: insertedStudents.length,
          skipped: skippedStudents.length
        }
      });
    } catch (error: any) {
      console.error('Bulk upload database error:', error);
      return NextResponse.json(
        { 
          success: false, 
          message: `Database error: ${error.message || 'Failed to process students'}`,
          error: 'DATABASE_ERROR'
        },
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('Bulk upload error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to upload students' },
      { status: 500 }
    );
  }
}
