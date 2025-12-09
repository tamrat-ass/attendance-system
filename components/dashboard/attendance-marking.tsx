'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { SimpleEthiopianDateInput } from '@/components/ui/simple-ethiopian-date-input';
import { Download } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { 
  getCurrentSimpleEthiopianDate, 
  simpleEthiopianToGregorian, 
  gregorianToSimpleEthiopian,
  formatSimpleEthiopianDate 
} from '@/lib/simple-ethiopian-date';

interface Student {
  id: number;
  full_name: string;
  phone: string;
  class: string;
  gender?: string;
}

interface AttendanceRecord {
  studentId: number;
  status: 'present' | 'absent' | 'late' | 'permission';
  date: string;
  notes?: string;
}

export default function AttendanceMarking() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedDate, setSelectedDate] = useState(() => {
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const gregorianDate = simpleEthiopianToGregorian(currentEthDate);
    console.log('Initial date - Ethiopian:', currentEthDate, 'Gregorian:', gregorianDate);
    return gregorianDate;
  });
  const [selectedClass, setSelectedClass] = useState('');
  const [studentStatus, setStudentStatus] = useState<{ [key: number]: 'present' | 'absent' | 'late' | 'permission' }>({});
  const [notes, setNotes] = useState<{ [key: number]: string }>({});
  const [searchStudent, setSearchStudent] = useState('');
  const [classes, setClasses] = useState<string[]>([]);
  const [lockedStudents, setLockedStudents] = useState<Set<number>>(new Set());
  const { toast } = useToast();

  // Fetch students from database
  const fetchStudents = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/students?limit=10000'); // Ensure we get all students
      const data = await response.json();
      
      if (response.ok) {
        const studentsData = data.data || [];
        setStudents(studentsData);
        
        // Extract unique classes and sort them
        const uniqueClasses = [...new Set(studentsData.map((s: Student) => s.class))].sort() as string[];
        setClasses(uniqueClasses);
        
        console.log('Total students loaded:', studentsData.length);
        console.log('Unique classes found:', uniqueClasses);
        
        // Set first class as default
        if (uniqueClasses.length > 0 && !selectedClass) {
          setSelectedClass(uniqueClasses[0] as string);
        }
      }
    } catch (err: any) {
      toast({
        title: "Error",
        description: "Failed to load students",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStudents();
  }, []);

  // Fetch existing attendance for selected date and class
  const fetchExistingAttendance = async () => {
    if (!selectedDate || !selectedClass) {
      setLockedStudents(new Set());
      return;
    }

    console.log('Fetching attendance for:', selectedDate, selectedClass);

    try {
      const response = await fetch(`/api/attendance?date=${selectedDate}&class=${selectedClass}`);
      const data = await response.json();

      console.log('Attendance API response:', data);

      if (response.ok && data.data && data.data.length > 0) {
        const existingStatus: { [key: number]: 'present' | 'absent' | 'late' | 'permission' } = {};
        const existingNotes: { [key: number]: string } = {};
        const locked = new Set<number>();

        data.data.forEach((record: any) => {
          existingStatus[record.student_id] = record.status;
          locked.add(record.student_id); // Lock only students with saved attendance
          if (record.notes) {
            existingNotes[record.student_id] = record.notes;
          }
        });

        console.log('Found existing attendance, locking students:', Array.from(locked));
        setStudentStatus(existingStatus);
        setNotes(existingNotes);
        setLockedStudents(locked);
      } else {
        // No existing attendance, unlock all
        console.log('No existing attendance found, unlocking all');
        setStudentStatus({});
        setNotes({});
        setLockedStudents(new Set());
      }
    } catch (error) {
      console.error('Error fetching existing attendance:', error);
      setLockedStudents(new Set());
    }
  };

  // Load existing attendance when date or class changes
  useEffect(() => {
    if (selectedDate && selectedClass) {
      fetchExistingAttendance();
    }
  }, [selectedDate, selectedClass]);

  // Filter students by search term (search across ALL classes) and then by selected class
  const classStudents = students
    .filter(s => 
      // If searching, search across ALL classes
      searchStudent === '' ||
      s.id.toString().includes(searchStudent) || 
      s.full_name.toLowerCase().includes(searchStudent.toLowerCase()) ||
      s.phone.includes(searchStudent)
    )
    .filter(s => 
      // If not searching, filter by selected class
      // If searching, show results from all classes
      searchStudent !== '' || s.class === selectedClass
    );

  // Handle status change for a student
  const handleStatusChange = (studentId: number, status: string) => {
    setStudentStatus({
      ...studentStatus,
      [studentId]: status as any
    });
  };

  // Handle notes change for a student
  const handleNotesChange = (studentId: number, note: string) => {
    setNotes({
      ...notes,
      [studentId]: note
    });
  };

  // Save attendance records
  const handleSaveAttendance = async () => {
    const markedCount = Object.keys(studentStatus).length;
    
    if (markedCount === 0) {
      toast({
        title: "No attendance marked",
        description: "Please mark attendance for at least one student",
        variant: "destructive"
      });
      return;
    }

    setLoading(true);
    try {
      // Prepare records for API
      const records = Object.keys(studentStatus).map(studentId => ({
        student_id: parseInt(studentId),
        date: selectedDate,
        status: studentStatus[parseInt(studentId)],
        notes: notes[parseInt(studentId)] || ''
      }));

      const response = await fetch('/api/attendance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ records })
      });

      const data = await response.json();

      if (response.ok) {
        toast({
          title: "Success",
          description: `Attendance saved for ${markedCount} students on ${selectedDate}`,
        });

        // Lock only the students that were just saved
        console.log('Attendance saved successfully, locking students');
        const newLocked = new Set(lockedStudents);
        Object.keys(studentStatus).forEach(id => newLocked.add(parseInt(id)));
        setLockedStudents(newLocked);
      } else {
        toast({
          title: "Error",
          description: data.message || "Failed to save attendance",
          variant: "destructive"
        });
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: "Failed to connect to server",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  // Mark all students as present
  const handleMarkAllPresent = () => {
    const newStatus: { [key: number]: 'present' | 'absent' | 'late' | 'permission' } = {};
    classStudents.forEach(student => {
      newStatus[student.id] = 'present';
    });
    setStudentStatus(newStatus);
  };

  // Mark all students as absent
  const handleMarkAllAbsent = () => {
    const newStatus: { [key: number]: 'present' | 'absent' | 'late' | 'permission' } = {};
    classStudents.forEach(student => {
      newStatus[student.id] = 'absent';
    });
    setStudentStatus(newStatus);
  };

  // Export attendance to CSV (current class only)
  const handleExportToExcel = () => {
    if (classStudents.length === 0) return;

    const data = classStudents.map(student => ({
      'Student ID': student.id,
      'Name': student.full_name,
      'Phone': student.phone,
      'Class': student.class,
      'Status': studentStatus[student.id] || 'Not Marked',
      'Notes': notes[student.id] || ''
    }));

    const headers = Object.keys(data[0]);
    const csv = [
      headers.join(','),
      ...data.map(row => 
        headers.map(h => `"${row[h as keyof typeof row]}"`).join(',')
      )
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `attendance-${selectedClass}-${selectedDate}.csv`;
    a.click();
  };

  // Export all attendance records (all classes)
  const handleExportAllAttendance = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/attendance?date=${selectedDate}`);
      const data = await response.json();

      if (response.ok && data.data && data.data.length > 0) {
        // Create a map of student IDs to student info
        const studentMap = new Map(students.map(s => [s.id, s]));

        const exportData = data.data.map((record: any) => {
          const student = studentMap.get(record.student_id);
          return {
            'Student ID': record.student_id,
            'Name': student?.full_name || 'Unknown',
            'Phone': student?.phone || '',
            'Class': student?.class || '',
            'Gender': student?.gender || '',
            'Status': record.status,
            'Notes': record.notes || '',
            'Date': record.date
          };
        });

        const headers = Object.keys(exportData[0]);
        const csv = [
          headers.join(','),
          ...exportData.map(row => 
            headers.map(h => `"${row[h as keyof typeof row]}"`).join(',')
          )
        ].join('\n');

        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `attendance-all-classes-${selectedDate}.csv`;
        a.click();

        toast({
          title: "Success",
          description: `Exported ${exportData.length} attendance records`,
        });
      } else {
        toast({
          title: "No Data",
          description: "No attendance records found for this date",
          variant: "destructive"
        });
      }
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to export attendance data",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <Card className="border-2">
        <CardHeader>
          <CardTitle>Mark Attendance</CardTitle>
          <CardDescription>Select date and class to mark attendance</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <SimpleEthiopianDateInput
                label="ቀን (Date)"
                value={selectedDate}
                onChange={setSelectedDate}
                useAmharic={true}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="class">Class</Label>
              <Select value={selectedClass} onValueChange={setSelectedClass}>
                <SelectTrigger>
                  <SelectValue placeholder="Select class" />
                </SelectTrigger>
                <SelectContent>
                  {classes.map((cls) => (
                    <SelectItem key={cls} value={cls}>{cls}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="searchStudent">Search Student</Label>
              <Input
                id="searchStudent"
                placeholder="Search by ID, name, or phone..."
                value={searchStudent}
                onChange={(e) => setSearchStudent(e.target.value)}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {loading ? (
        <Card className="border-2">
          <CardContent className="py-12 text-center text-muted-foreground">
            Loading students...
          </CardContent>
        </Card>
      ) : classStudents.length > 0 ? (
        <Card className="border-2">
          <CardHeader>
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div>
                <CardTitle>{selectedClass} - {classStudents.length} Students</CardTitle>
                <CardDescription>
                  Mark attendance for {formatSimpleEthiopianDate(gregorianToSimpleEthiopian(selectedDate), true)}
                </CardDescription>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" onClick={handleMarkAllPresent} size="sm">
                  Mark All Present
                </Button>
                <Button variant="outline" onClick={handleMarkAllAbsent} size="sm">
                  Mark All Absent
                </Button>
              </div>
            </div>
            <div className="flex flex-wrap gap-4 mt-4 text-sm">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded bg-green-600 text-white flex items-center justify-center">✓</div>
                <span>Present</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded bg-red-600 text-white flex items-center justify-center">✗</div>
                <span>Absent</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded bg-yellow-600 text-white flex items-center justify-center">⏰</div>
                <span>Late</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded bg-blue-600 text-white flex items-center justify-center">📝</div>
                <span>Permission</span>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="rounded-lg border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-20">ID</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead className="w-24">Gender</TableHead>
                    <TableHead className="w-32">Phone</TableHead>
                    <TableHead className="w-32">Class</TableHead>
                    <TableHead className="w-48">Mark Status</TableHead>
                    <TableHead>Notes (Optional)</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {classStudents.map((student) => (
                    <TableRow key={student.id}>
                      <TableCell className="font-mono text-sm">{student.id}</TableCell>
                      <TableCell className="font-medium">{student.full_name}</TableCell>
                      <TableCell className="text-sm">{student.gender || 'Male'}</TableCell>
                      <TableCell>{student.phone}</TableCell>
                      <TableCell className="font-medium">{student.class}</TableCell>
                      <TableCell>
                        <div className="flex gap-1.5">
                          <Button
                            type="button"
                            size="sm"
                            variant={studentStatus[student.id] === 'present' ? 'default' : 'outline'}
                            className={
                              studentStatus[student.id] === 'present' 
                                ? 'bg-green-600 hover:bg-green-700 text-white border-green-600' 
                                : 'hover:bg-green-50 hover:text-green-700 hover:border-green-300'
                            }
                            onClick={() => handleStatusChange(student.id, 'present')}
                            disabled={lockedStudents.has(student.id)}
                          >
                            ✓
                          </Button>
                          <Button
                            type="button"
                            size="sm"
                            variant={studentStatus[student.id] === 'absent' ? 'default' : 'outline'}
                            className={
                              studentStatus[student.id] === 'absent' 
                                ? 'bg-red-600 hover:bg-red-700 text-white border-red-600' 
                                : 'hover:bg-red-50 hover:text-red-700 hover:border-red-300'
                            }
                            onClick={() => handleStatusChange(student.id, 'absent')}
                            disabled={lockedStudents.has(student.id)}
                          >
                            ✗
                          </Button>
                          <Button
                            type="button"
                            size="sm"
                            variant={studentStatus[student.id] === 'late' ? 'default' : 'outline'}
                            className={
                              studentStatus[student.id] === 'late' 
                                ? 'bg-yellow-600 hover:bg-yellow-700 text-white border-yellow-600' 
                                : 'hover:bg-yellow-50 hover:text-yellow-700 hover:border-yellow-300'
                            }
                            onClick={() => handleStatusChange(student.id, 'late')}
                            disabled={lockedStudents.has(student.id)}
                          >
                            ⏰
                          </Button>
                          <Button
                            type="button"
                            size="sm"
                            variant={studentStatus[student.id] === 'permission' ? 'default' : 'outline'}
                            className={
                              studentStatus[student.id] === 'permission' 
                                ? 'bg-blue-600 hover:bg-blue-700 text-white border-blue-600' 
                                : 'hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300'
                            }
                            onClick={() => handleStatusChange(student.id, 'permission')}
                            disabled={lockedStudents.has(student.id)}
                          >
                            📝
                          </Button>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Input
                          placeholder="Add note (optional)"
                          value={notes[student.id] || ''}
                          onChange={(e) => handleNotesChange(student.id, e.target.value)}
                          className="text-sm"
                          disabled={lockedStudents.has(student.id)}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>

            <div className="mt-4 flex gap-2 flex-wrap">
              <Button onClick={handleSaveAttendance} size="lg">
                💾 Save Attendance
              </Button>
              <Button onClick={handleExportToExcel} variant="outline" size="lg" className="flex items-center gap-2">
                <Download className="w-4 h-4" />
                <span>ወደ CSV ላክ (የተመረጠው ክፍል)</span>
              </Button>
              <Button onClick={handleExportAllAttendance} variant="outline" size="lg" className="flex items-center gap-2">
                <Download className="w-4 h-4" />
                <span>ወደ CSV ላክ (ሁሉም ክፍሎች)</span>
              </Button>
            </div>
          </CardContent>
        </Card>
      ) : (
        <Card className="border-2">
          <CardContent className="py-12 text-center text-muted-foreground">
            {students.length === 0 
              ? '📚 No students found. Add students first in the Students tab.' 
              : selectedClass 
                ? `No students found in ${selectedClass}` 
                : 'Please select a class'}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
