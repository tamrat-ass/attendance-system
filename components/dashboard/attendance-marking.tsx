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
import { usePerformance } from '@/hooks/use-performance';
import { 
  getCurrentSimpleEthiopianDate, 
  simpleEthiopianToDbFormat,
  simpleEthiopianToGregorian, 
  gregorianToSimpleEthiopian,
  dbFormatToSimpleEthiopian,
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
  status: 'present' | 'absent' | 'late' | 'permission' | 'sick' | 'excused';
  date: string;
  notes?: string;
}

export default function AttendanceMarking() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);
  const { metrics, measureApiCall } = usePerformance('AttendanceMarking');
  const [selectedDate, setSelectedDate] = useState(() => {
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const ethiopianDbDate = simpleEthiopianToDbFormat(currentEthDate);
    console.log('Initial date - Ethiopian:', currentEthDate, 'DB Format:', ethiopianDbDate);
    return ethiopianDbDate;
  });
  const [selectedClass, setSelectedClass] = useState('');
  const [studentStatus, setStudentStatus] = useState<{ [key: number]: 'present' | 'absent' | 'late' | 'permission' }>({});
  const [notes, setNotes] = useState<{ [key: number]: string }>({});
  const [searchStudent, setSearchStudent] = useState('');
  const [classes, setClasses] = useState<string[]>([]);
  const [lockedStudents, setLockedStudents] = useState<Set<number>>(new Set());
  const { toast } = useToast();

  // Smart Search Helper Functions
  const getSmartSearchPlaceholder = (input: string) => {
    if (!input) return "Type 09... for phone, numbers for ID, or text for name";
    
    const trimmed = input.trim();
    if (/^09/.test(trimmed) && trimmed.length < 10) {
      return "Continue typing phone number (09xxxxxxxx)";
    } else if (/^09\d{8}$/.test(trimmed)) {
      return "Phone number search active";
    } else if (/^\d+$/.test(trimmed)) {
      return "Student ID search active";
    } else {
      return "Name/class search active";
    }
  };

  const getSearchTypeHint = (input: string) => {
    if (!input) return "";
    
    const trimmed = input.trim();
    if (/^09\d{8}$/.test(trimmed)) {
      return "🔍 Searching by phone number (exact match)";
    } else if (/^\d+$/.test(trimmed)) {
      return "🔍 Searching by student ID (exact match)";
    } else {
      return "🔍 Searching by name or class (partial match across all classes)";
    }
  };

  // Load classes from classes API (not from existing students)
  const loadClassesFromAPI = async () => {
    try {
      const response = await fetch('/api/classes', {
        cache: 'no-store',
        headers: { 'Cache-Control': 'no-cache' }
      });
      
      if (response.ok) {
        const data = await response.json();
        const classesData = data.data || [];
        const classNames = classesData.map((c: any) => c.name).sort();
        setClasses(classNames);
        
        console.log('Classes loaded from API:', classNames);
        
        // Set first class as default
        if (classNames.length > 0 && !selectedClass) {
          setSelectedClass(classNames[0]);
        }
      } else {
        // Fallback: extract from existing students if API fails
        const uniqueClasses = [...new Set(students.map((s: Student) => s.class))].sort() as string[];
        setClasses(uniqueClasses);
        console.log('Fallback: Classes from students:', uniqueClasses);
      }
    } catch (err) {
      // Fallback: extract from existing students if API fails
      const uniqueClasses = [...new Set(students.map((s: Student) => s.class))].sort() as string[];
      setClasses(uniqueClasses);
      console.log('Error loading classes, using fallback:', uniqueClasses);
    }
  };

  // Fetch students from database
  const fetchStudents = async () => {
    setLoading(true);
    try {
      const data = await measureApiCall(
        async () => {
          // Check cache first
          const { apiCache } = await import('@/lib/cache');
          const cacheKey = 'students-list';
          const cached = apiCache.get(cacheKey);
          
          if (cached) {
            console.log('Using cached students data');
            return cached;
          }

          const response = await fetch('/api/students?limit=10000');
          if (!response.ok) {
            throw new Error('Failed to fetch students');
          }
          const result = await response.json();
          
          // Cache for 5 minutes
          apiCache.set(cacheKey, result, 300);
          return result;
        },
        'fetchStudents'
      );
      
      const studentsData = data.data || [];
      setStudents(studentsData);
      
      console.log('Total students loaded:', studentsData.length);
      
      // Load classes from classes table (not from existing students)
      await loadClassesFromAPI();
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
    
    // Always sync to today's date on component mount
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const ethiopianDbDate = simpleEthiopianToDbFormat(currentEthDate);
    setSelectedDate(ethiopianDbDate);
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

  // Smart Search Logic - Filter students by search term
  const classStudents = students
    .filter(s => {
      if (searchStudent === '') {
        // No search term - show only selected class
        return s.class === selectedClass;
      }
      
      const trimmedSearch = searchStudent.trim();
      
      // Smart Search Logic
      if (/^09\d{8}$/.test(trimmedSearch)) {
        // Phone number search (09xxxxxxxx - exact match)
        return s.phone === trimmedSearch;
      } else if (/^\d+$/.test(trimmedSearch)) {
        // Student ID search (digits only, not starting with 09)
        return s.id.toString() === trimmedSearch;
      } else {
        // Name search (contains letters or mixed characters) - search across ALL classes
        return s.full_name.toLowerCase().includes(trimmedSearch.toLowerCase()) ||
               s.class.toLowerCase().includes(trimmedSearch.toLowerCase());
      }
    });

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

  // Mark all UNMARKED students from ALL CLASSES as permission and auto-save
  const handleMarkAllPermission = async () => {
    setLoading(true);
    try {
      // Get existing attendance for this date across ALL classes
      const response = await fetch(`/api/attendance?date=${selectedDate}`);
      const existingData = await response.json();
      
      // Create a set of student IDs who already have attendance
      const markedStudentIds = new Set();
      if (response.ok && existingData.data) {
        existingData.data.forEach((record: any) => {
          markedStudentIds.add(record.student_id);
        });
      }
      
      // Find all unmarked students from ALL classes
      const unmarkedStudents = students.filter(student => !markedStudentIds.has(student.id));
      
      if (unmarkedStudents.length === 0) {
        toast({
          title: "No Action Needed",
          description: "All students in all classes already have attendance marked",
        });
        setLoading(false);
        return;
      }
      
      // Prepare records for ALL unmarked students
      const records = unmarkedStudents.map(student => ({
        student_id: student.id,
        date: selectedDate,
        status: 'permission',
        notes: ''
      }));

      // Save attendance for all unmarked students
      const saveResponse = await fetch('/api/attendance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ records })
      });

      if (saveResponse.ok) {
        toast({
          title: "Success",
          description: `Marked ${unmarkedStudents.length} students from all classes as permission for ${selectedDate}`,
        });
        
        // Refresh the current class view
        fetchExistingAttendance();
      } else {
        const errorData = await saveResponse.json();
        toast({
          title: "Error",
          description: errorData.message || "Failed to save attendance",
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

  // Helper function to save attendance with custom status
  const saveAttendanceWithStatus = async (statusToSave: { [key: number]: 'present' | 'absent' | 'late' | 'permission' }, successMessage: string) => {
    setLoading(true);
    try {
      // Prepare records for API
      const records = Object.keys(statusToSave).map(studentId => ({
        student_id: parseInt(studentId),
        date: selectedDate,
        status: statusToSave[parseInt(studentId)],
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
          description: `${successMessage} and saved for ${selectedDate}`,
        });

        // Lock the students that were just saved
        const newLocked = new Set(lockedStudents);
        Object.keys(statusToSave).forEach(id => newLocked.add(parseInt(id)));
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

  // Export attendance to CSV (current class only)
  const handleExportToExcel = () => {
    if (classStudents.length === 0) return;

    // Helper function to translate status to Amharic
    const translateStatus = (status: string) => {
      const statusMap: { [key: string]: string } = {
        'present': 'የተገኘበት',
        'absent': 'ቀሪ', 
        'late': 'ያረፈደ ',
        'permission': 'ፈቃድ',
        'Not Marked': 'አልተመዘገበም'
      };
      return statusMap[status] || status;
    };

    // Define the type for Amharic export data
    type AmharicExportRow = {
      'የተማሪ መለያ': number;
      'ስም': string;
      'ስልክ': string;
      'ክፍል': string;
      'ሁኔታ': string;
      'ማስታወሻ': string;
    };

    const data: AmharicExportRow[] = classStudents.map(student => ({
      'የተማሪ መለያ': student.id,
      'ስም': student.full_name,
      'ስልክ': student.phone,
      'ክፍል': student.class,
      'ሁኔታ': translateStatus(studentStatus[student.id] || 'Not Marked'),
      'ማስታወሻ': notes[student.id] || ''
    }));

    const headers = Object.keys(data[0]) as (keyof AmharicExportRow)[];
    const csv = [
      headers.join(','),
      ...data.map((row: AmharicExportRow) => 
        headers.map(h => `"${row[h]}"`).join(',')
      )
    ].join('\n');

    // Add UTF-8 BOM for proper encoding in Excel
    const BOM = '\uFEFF';
    const blob = new Blob([BOM + csv], { type: 'text/csv;charset=utf-8;' });
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

        // Define the type for export data
        type ExportRow = {
          'Student ID': number;
          'Name': string;
          'Phone': string;
          'Class': string;
          'Gender': string;
          'Status': string;
          'Notes': string;
          'Date': string;
        };

        const exportData: ExportRow[] = data.data.map((record: any) => {
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

        const headers = Object.keys(exportData[0]) as (keyof ExportRow)[];
        const csv = [
          headers.join(','),
          ...exportData.map((row: ExportRow) => 
            headers.map(h => `"${row[h]}"`).join(',')
          )
        ].join('\n');

        // Add UTF-8 BOM for proper encoding in Excel
        const BOM = '\uFEFF';
        const blob = new Blob([BOM + csv], { type: 'text/csv;charset=utf-8;' });
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
    <div className="space-y-4 sm:space-y-6 p-2 sm:p-0">
      <Card className="border-2">
        <CardHeader className="pb-4">
          <CardTitle className="text-lg sm:text-xl">Mark Attendance</CardTitle>
          <CardDescription className="text-sm">Select date and class to mark attendance</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
            <div className="space-y-2">
              <SimpleEthiopianDateInput
                key={selectedDate}
                label="ቀን (Date)"
                value={selectedDate}
                onChange={setSelectedDate}
                useAmharic={true}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="class" className="text-sm font-medium">Class</Label>
              <Select value={selectedClass} onValueChange={setSelectedClass}>
                <SelectTrigger className="h-10">
                  <SelectValue placeholder="Select class" />
                </SelectTrigger>
                <SelectContent>
                  {classes.map((cls) => (
                    <SelectItem key={cls} value={cls}>{cls}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2 sm:col-span-2 lg:col-span-1">
              <Label htmlFor="searchStudent" className="text-sm font-medium">🔍 Smart Search</Label>
              <Input
                id="searchStudent"
                placeholder={getSmartSearchPlaceholder(searchStudent)}
                value={searchStudent}
                onChange={(e) => setSearchStudent(e.target.value)}
                className="h-10"
              />
              {searchStudent && (
                <p className="text-xs text-muted-foreground">
                  {getSearchTypeHint(searchStudent)}
                </p>
              )}
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
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                  <CardTitle className="text-lg sm:text-xl">{selectedClass} - {classStudents.length} Students</CardTitle>
                  <CardDescription className="text-sm">
                    Mark attendance for {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(selectedDate), true)}
                  </CardDescription>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" onClick={handleMarkAllPermission} size="sm" className="text-xs sm:text-sm">
                    Mark All Permission
                  </Button>
                </div>
              </div>
              
              {/* Status Legend - Mobile Optimized */}
              <div className="grid grid-cols-2 sm:flex sm:flex-wrap gap-2 sm:gap-4 text-xs sm:text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 sm:w-8 sm:h-8 rounded bg-green-600 text-white flex items-center justify-center text-xs">✓</div>
                  <span>Present</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 sm:w-8 sm:h-8 rounded bg-red-600 text-white flex items-center justify-center text-xs">✗</div>
                  <span>Absent</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 sm:w-8 sm:h-8 rounded bg-yellow-600 text-white flex items-center justify-center text-xs">⏰</div>
                  <span>Late</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 sm:w-8 sm:h-8 rounded bg-blue-600 text-white flex items-center justify-center text-xs">📝</div>
                  <span>Permission</span>
                </div>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {/* Mobile Card Layout */}
            <div className="block lg:hidden space-y-3">
              {classStudents.map((student) => (
                <Card key={student.id} className="border">
                  <CardContent className="p-4">
                    <div className="flex flex-col gap-3">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h3 className="font-medium text-sm">{student.full_name}</h3>
                          <p className="text-xs text-muted-foreground">ID: {student.id} • {student.class} • {student.phone}</p>
                        </div>
                      </div>
                      
                      <div className="grid grid-cols-4 gap-1">
                        <Button
                          type="button"
                          size="sm"
                          variant={studentStatus[student.id] === 'present' ? 'default' : 'outline'}
                          className={
                            studentStatus[student.id] === 'present' 
                              ? 'bg-green-600 hover:bg-green-700 text-white border-green-600 h-8 text-xs' 
                              : 'hover:bg-green-50 hover:text-green-700 hover:border-green-300 h-8 text-xs'
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
                              ? 'bg-red-600 hover:bg-red-700 text-white border-red-600 h-8 text-xs' 
                              : 'hover:bg-red-50 hover:text-red-700 hover:border-red-300 h-8 text-xs'
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
                              ? 'bg-yellow-600 hover:bg-yellow-700 text-white border-yellow-600 h-8 text-xs' 
                              : 'hover:bg-yellow-50 hover:text-yellow-700 hover:border-yellow-300 h-8 text-xs'
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
                              ? 'bg-blue-600 hover:bg-blue-700 text-white border-blue-600 h-8 text-xs' 
                              : 'hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300 h-8 text-xs'
                          }
                          onClick={() => handleStatusChange(student.id, 'permission')}
                          disabled={lockedStudents.has(student.id)}
                        >
                          📝
                        </Button>
                      </div>
                      
                      <Input
                        placeholder="Add note (optional)"
                        value={notes[student.id] || ''}
                        onChange={(e) => handleNotesChange(student.id, e.target.value)}
                        className="text-sm h-8"
                        disabled={lockedStudents.has(student.id)}
                      />
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>

            {/* Desktop Table Layout */}
            <div className="hidden lg:block rounded-lg border overflow-x-auto">
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

            <div className="mt-4 flex flex-col sm:flex-row gap-2">
              <Button onClick={handleSaveAttendance} size="sm" className="w-full sm:w-auto">
                💾 Save Attendance
              </Button>
              <Button onClick={handleExportToExcel} variant="outline" size="sm" className="flex items-center justify-center gap-2 w-full sm:w-auto">
                <Download className="w-4 h-4" />
                <span className="hidden sm:inline">Export CSV (Current Class)</span>
                <span className="sm:hidden">Export Current</span>
              </Button>
              <Button onClick={handleExportAllAttendance} variant="outline" size="sm" className="flex items-center justify-center gap-2 w-full sm:w-auto">
                <Download className="w-4 h-4" />
                <span className="hidden sm:inline">Export CSV (All Classes)</span>
                <span className="sm:hidden">Export All</span>
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
