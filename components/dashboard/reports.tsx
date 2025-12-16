'use client';

import { useMemo, useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Download, X, FileSpreadsheet } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { 
  getCurrentSimpleEthiopianDate, 
  simpleEthiopianToDbFormat,
  dbFormatToSimpleEthiopian,
  formatSimpleEthiopianDate 
} from '@/lib/simple-ethiopian-date';
import ReportsDebug from './reports-debug';
import * as XLSX from 'xlsx';

interface Student {
  id: number;
  full_name: string;
  phone: string;
  class: string;
}

interface AttendanceRecord {
  id: number;
  student_id: number;
  date: string;
  status: 'present' | 'absent' | 'late' | 'permission';
  notes: string;
  full_name: string;
  phone: string;
  class: string;
}

export default function Reports() {
  const [students, setStudents] = useState<Student[]>([]);
  const [attendance, setAttendance] = useState<AttendanceRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedFilter, setSelectedFilter] = useState<'all' | 'present' | 'absent' | 'late' | 'permission'>('all');
  const { toast } = useToast();

  // Use Ethiopian dates since that's how they're stored in the database
  const [startDate, setStartDate] = useState(() => {
    // Start from beginning of current Ethiopian month
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const startEthDate = { ...currentEthDate, day: 1 };
    const ethiopianStart = `${startEthDate.year.toString().padStart(4, '0')}-${startEthDate.month.toString().padStart(2, '0')}-${startEthDate.day.toString().padStart(2, '0')}`;
    console.log('Initial start date (Ethiopian DB format):', ethiopianStart);
    return ethiopianStart;
  });
  const [endDate, setEndDate] = useState(() => {
    // End at current Ethiopian date
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const ethiopianEnd = `${currentEthDate.year.toString().padStart(4, '0')}-${currentEthDate.month.toString().padStart(2, '0')}-${currentEthDate.day.toString().padStart(2, '0')}`;
    console.log('Initial end date (Ethiopian DB format):', ethiopianEnd);
    return ethiopianEnd;
  });

  // Fetch students and attendance
  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch students - get ALL students without limit
      const studentsRes = await fetch('/api/students?limit=99999');
      const studentsData = await studentsRes.json();
      
      // Fetch attendance with date range
      const attendanceUrl = `/api/attendance?start_date=${startDate}&end_date=${endDate}`;
      console.log('Fetching attendance from:', attendanceUrl);
      const attendanceRes = await fetch(attendanceUrl);
      const attendanceData = await attendanceRes.json();
      console.log('Attendance API response:', attendanceData);

      if (studentsRes.ok && studentsData.data) {
        setStudents(studentsData.data);
        console.log('Students loaded:', studentsData.data.length);
      } else {
        console.error('Failed to load students:', studentsData);
        toast({
          title: "Error",
          description: "Failed to load students data",
          variant: "destructive"
        });
      }

      if (attendanceRes.ok && attendanceData.data) {
        setAttendance(attendanceData.data);
        console.log('Attendance records loaded:', attendanceData.data.length);
      } else {
        console.error('Failed to load attendance:', attendanceData);
        toast({
          title: "Error", 
          description: "Failed to load attendance data",
          variant: "destructive"
        });
      }
    } catch (error: any) {
      console.error('Fetch error:', error);
      toast({
        title: "Error",
        description: `Failed to load report data: ${error.message}`,
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [startDate, endDate]);

  const stats = useMemo(() => {
    console.log('Computing stats with:', { 
      studentsCount: students.length, 
      attendanceCount: attendance.length,
      startDate,
      endDate
    });
    
    // Always calculate stats for all students, even if no attendance data
    const presentCount = attendance.filter(a => a.status === 'present').length;
    const absentCount = attendance.filter(a => a.status === 'absent').length;
    const lateCount = attendance.filter(a => a.status === 'late').length;
    const permissionCount = attendance.filter(a => a.status === 'permission').length;

    // Group by date
    const byDate: { [key: string]: { [key: string]: number } } = {};
    attendance.forEach(record => {
      if (!byDate[record.date]) {
        byDate[record.date] = { present: 0, absent: 0, late: 0, permission: 0 };
      }
      byDate[record.date][record.status]++;
    });

    const dateChartData = Object.entries(byDate)
      .sort(([dateA], [dateB]) => dateA.localeCompare(dateB))
      .map(([date, counts]) => {
        // Date is already in Ethiopian format from database
        const ethDate = dbFormatToSimpleEthiopian(date);
        return {
          date: `${ethDate.day}/${ethDate.month}`,
          present: counts.present,
          absent: counts.absent,
          late: counts.late,
          permission: counts.permission
        };
      });

    const pieData = [
      { name: 'Present', value: presentCount },
      { name: 'Absent', value: absentCount },
      { name: 'Late', value: lateCount },
      { name: 'Permission', value: permissionCount }
    ];

    // Calculate student stats - INCLUDE ALL STUDENTS, even those with no attendance
    const byClass: { [key: string]: { [key: string]: number } } = {};
    const studentStats = students.map(student => {
      const records = attendance.filter(a => a.student_id === student.id);
      const present = records.filter(r => r.status === 'present').length;
      const absent = records.filter(r => r.status === 'absent').length;
      const late = records.filter(r => r.status === 'late').length;
      const permission = records.filter(r => r.status === 'permission').length;
      const attendanceRate = records.length > 0 ? ((present / records.length) * 100).toFixed(1) : '0';

      if (!byClass[student.class]) {
        byClass[student.class] = { present: 0, absent: 0, total: 0 };
      }
      byClass[student.class].present += present;
      byClass[student.class].absent += absent;
      byClass[student.class].total += records.length;

      return {
        ...student,
        total: records.length,
        present,
        absent,
        late,
        permission,
        attendanceRate: parseFloat(attendanceRate)
      };
    }); // REMOVED FILTER - Show ALL students, including those with 0 attendance

    const classStats = Object.entries(byClass).map(([className, stats]) => ({
      class: className,
      ...stats
    }));

    return {
      totalRecords: students.length, // FIXED: Total number of students in system
      totalStudentsWithAttendance: studentStats.filter(s => s.total > 0).length, // Students with attendance records
      presentCount,
      absentCount,
      lateCount,
      permissionCount,
      dateChartData,
      pieData,
      studentStats,
      classStats
    };
  }, [students, attendance]);



  const handleExportExcel = () => {
    if (stats.studentStats.length === 0) {
      toast({
        title: "No data",
        description: "No attendance data to export",
        variant: "destructive"
      });
      return;
    }

    try {
      // Calculate total study days in the date range
      const startEthDate = dbFormatToSimpleEthiopian(startDate);
      const endEthDate = dbFormatToSimpleEthiopian(endDate);
      
      // Simple calculation of days between dates (Ethiopian calendar)
      const totalStudyDays = Math.abs(
        (endEthDate.year * 365 + endEthDate.month * 30 + endEthDate.day) - 
        (startEthDate.year * 365 + startEthDate.month * 30 + startEthDate.day)
      ) + 1;

      const startEthDateFormatted = formatSimpleEthiopianDate(startEthDate, true);
      const endEthDateFormatted = formatSimpleEthiopianDate(endEthDate, true);
      
      // Create the report data with exact Amharic column names as requested
      const reportData = [
        // Title rows
        [`የማህበረ ቅዱሳን የመዝሙር ክፍል የአባላይ መከታተያ`],
        [`Attendance Report (${startEthDateFormatted} to ${endEthDateFormatted})`],
        [], // Empty row
        // Header row with exact columns as requested
        [
          'የአባላቱ መለያ',
          'ሙሉ ስም', 
          'የሚያገለግሉበት ክፍል',
          'ስልክ',
          'ጠቅላላ የጥናት ቀናት',
          'የተኘበት ቀን',
          'የቀረበት ቀን', 
          'ዘግይቶ የመጣበት',
          'ፈቃድ የተጠየቀበት',
          'ጠቅላላ የተገኙበት ቀናት',
          'የመጣበት መጠን በ%'
        ]
      ];

      // Add student data rows
      stats.studentStats.forEach(student => {
        const totalAttendedDays = student.present + student.permission;
        reportData.push([
          student.id.toString(),
          student.full_name,
          student.class,
          student.phone,
          totalStudyDays.toString(),
          student.absent.toString(),
          student.present.toString(),
          student.late.toString(),
          student.permission.toString(),
          totalAttendedDays.toString(),
          `${student.attendanceRate}%`
        ]);
      });

      // Create workbook and worksheet
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.aoa_to_sheet(reportData);
      
      // Set column widths for better readability
      worksheet['!cols'] = [
        { width: 12 }, // የአባላቱ መለያ
        { width: 25 }, // ሙሉ ስም
        { width: 20 }, // የሚያገለግሉበት ክፍል
        { width: 15 }, // ስልክ
        { width: 18 }, // ጠቅላላ የጥናት ቀናት
        { width: 15 }, // የተኘበት ቀን
        { width: 15 }, // የቀረበት ቀን
        { width: 18 }, // ዘግይቶ የመጣበት
        { width: 20 }, // ፈቃድ የተጠየቀበት
        { width: 22 }, // ጠቅላላ የተገኙበት ቀናት
        { width: 18 }  // የመጣበት መጠን በ%
      ];
      
      // Style the title rows
      const titleStyle = {
        font: { bold: true, size: 14, color: { rgb: "000080" } },
        alignment: { horizontal: "center" }
      };
      
      // Style the header row
      const headerStyle = {
        font: { bold: true, color: { rgb: "FFFFFF" } },
        fill: { fgColor: { rgb: "366092" } },
        alignment: { horizontal: "center" },
        border: {
          top: { style: "thin" },
          bottom: { style: "thin" },
          left: { style: "thin" },
          right: { style: "thin" }
        }
      };
      
      // Apply title styling
      if (worksheet['A1']) worksheet['A1'].s = titleStyle;
      if (worksheet['A2']) worksheet['A2'].s = titleStyle;
      
      // Apply header styling (row 4)
      const headerRow = 4;
      for (let col = 0; col < 11; col++) {
        const cellAddress = XLSX.utils.encode_cell({ r: headerRow - 1, c: col });
        if (worksheet[cellAddress]) {
          worksheet[cellAddress].s = headerStyle;
        }
      }
      
      // Merge title cells
      worksheet['!merges'] = [
        { s: { r: 0, c: 0 }, e: { r: 0, c: 10 } }, // Title row
        { s: { r: 1, c: 0 }, e: { r: 1, c: 10 } }  // Subtitle row
      ];
      
      // Add worksheet to workbook
      XLSX.utils.book_append_sheet(workbook, worksheet, 'የአባላይ መከታተያ');
      
      // Generate Excel file
      const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
      const blob = new Blob([excelBuffer], { 
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
      });
      
      // Download file
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `የአባላይ-መከታተያ-${startEthDateFormatted}-to-${endEthDateFormatted}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      
      toast({
        title: "Success",
        description: "የአባላይ መከታተያ ሪፖርት በተሳካ ሁኔታ ወርዷል (Excel report exported successfully)",
      });
    } catch (error) {
      console.error('Excel export error:', error);
      toast({
        title: "Export Failed",
        description: "Failed to create Excel report. Try again.",
        variant: "destructive"
      });
    }
  };

  const handleExportReport = () => {
    if (stats.studentStats.length === 0) {
      toast({
        title: "No data",
        description: "No attendance data to export",
        variant: "destructive"
      });
      return;
    }

    // Calculate total study days in the date range
    const startEthDate = dbFormatToSimpleEthiopian(startDate);
    const endEthDate = dbFormatToSimpleEthiopian(endDate);
    
    // Simple calculation of days between dates (Ethiopian calendar)
    const totalStudyDays = Math.abs(
      (endEthDate.year * 365 + endEthDate.month * 30 + endEthDate.day) - 
      (startEthDate.year * 365 + startEthDate.month * 30 + startEthDate.day)
    ) + 1;

    const data = stats.studentStats.map(student => {
      // Calculate Total Attended Days (Present + Permission)
      const totalAttendedDays = student.present + student.permission;
      
      return {
        'የአባላቱ መለያ': student.id,
        'ሙሉ ስም': student.full_name,
        'የሚያገለግሉበት ክፍል': student.class,
        'ስልክ': student.phone,
        'ጠቅላላ የጥናት ቀናት': totalStudyDays,
        'የተኘበት ቀን': student.absent,
        'የቀረበት ቀን': student.present,
        'ዘግይቶ የመጣበት': student.late,
        'ፈቃድ የተጠየቀበት': student.permission,
        'ጠቅላላ የተገኙበት ቀናት': totalAttendedDays,
        'የመጣበት መጠን በ%': `${student.attendanceRate}%`
      };
    });

    const headers = Object.keys(data[0]);
    const startEthDateFormatted = formatSimpleEthiopianDate(startEthDate, true);
    const endEthDateFormatted = formatSimpleEthiopianDate(endEthDate, true);
    
    // Create the report with proper Amharic header
    const reportTitle = `የማህበረ ቅዱሳን የመዝሙር ክፍል የአባላይ መከታተያ`;
    const reportSubtitle = `Attendance Report (${startEthDateFormatted} to ${endEthDateFormatted})`;
    
    const csv = [
      reportTitle,
      reportSubtitle,
      '',
      headers.join(','),
      ...data.map(row => 
        headers.map(h => `"${row[h as keyof typeof row]}"`).join(',')
      )
    ].join('\n');

    // Add UTF-8 BOM for proper Amharic character display in Excel
    const BOM = '\uFEFF';
    const blob = new Blob([BOM + csv], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `የአባላይ-መከታተያ-${startEthDateFormatted}-to-${endEthDateFormatted}.csv`;
    a.click();

    toast({
      title: "Success",
      description: "የአባላይ መከታተያ ሪፖርት በተሳካ ሁኔታ ወርዷል (Report exported successfully)",
    });
  };

  return (
    <div className="space-y-6">
      {/* Debug Tool - Remove in production */}
      {process.env.NODE_ENV === 'development' && (
        <ReportsDebug />
      )}
      
      {/* Date Range Filter */}
      <Card className="border-2">
        <CardHeader>
          <CardTitle>Report Filter</CardTitle>
          <CardDescription>Select Ethiopian date range to view attendance reports</CardDescription>
        </CardHeader>
        <CardContent>
          {/* Quick Date Presets */}
          <div className="flex flex-wrap gap-2 mb-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const currentEthDate = getCurrentSimpleEthiopianDate();
                const todayEth = simpleEthiopianToDbFormat(currentEthDate);
                setStartDate(todayEth);
                setEndDate(todayEth);
              }}
            >
              Today
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const currentEthDate = getCurrentSimpleEthiopianDate();
                const endEth = simpleEthiopianToDbFormat(currentEthDate);
                // Go back 7 days in Ethiopian calendar
                const startEthDate = { ...currentEthDate, day: Math.max(1, currentEthDate.day - 7) };
                if (startEthDate.day > currentEthDate.day) {
                  // Went to previous month
                  startEthDate.month = Math.max(1, startEthDate.month - 1);
                  if (startEthDate.month === 13) {
                    startEthDate.day = Math.min(6, startEthDate.day + 30);
                  } else {
                    startEthDate.day = Math.min(30, startEthDate.day + 30);
                  }
                }
                const startEth = simpleEthiopianToDbFormat(startEthDate);
                setStartDate(startEth);
                setEndDate(endEth);
              }}
            >
              Last 7 Days
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const currentEthDate = getCurrentSimpleEthiopianDate();
                const endEth = simpleEthiopianToDbFormat(currentEthDate);
                // Start from beginning of current Ethiopian month
                const startEthDate = { ...currentEthDate, day: 1 };
                const startEth = simpleEthiopianToDbFormat(startEthDate);
                setStartDate(startEth);
                setEndDate(endEth);
              }}
            >
              This Month
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const currentEthDate = getCurrentSimpleEthiopianDate();
                const endEth = simpleEthiopianToDbFormat(currentEthDate);
                // Go back to previous month
                const startEthDate = { 
                  ...currentEthDate, 
                  month: currentEthDate.month === 1 ? 13 : currentEthDate.month - 1,
                  day: 1 
                };
                if (startEthDate.month === 13) {
                  startEthDate.year = currentEthDate.year - 1;
                }
                const startEth = simpleEthiopianToDbFormat(startEthDate);
                setStartDate(startEth);
                setEndDate(endEth);
              }}
            >
              Last Month
            </Button>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label htmlFor="start-date">ከ ቀን (From Date)</Label>
              <Input
                id="start-date"
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full"
                placeholder="YYYY-MM-DD (Ethiopian)"
              />
              <p className="text-xs text-muted-foreground">
                Ethiopian: {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(startDate), true)}
              </p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="end-date">እስከ ቀን (To Date)</Label>
              <Input
                id="end-date"
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="w-full"
                placeholder="YYYY-MM-DD (Ethiopian)"
              />
              <p className="text-xs text-muted-foreground">
                Ethiopian: {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(endDate), true)}
              </p>
            </div>
            <div className="flex items-end gap-2">
              <Button 
                onClick={fetchData} 
                variant="outline" 
                className="flex items-center gap-2" 
                disabled={loading}
              >
                🔄 Refresh
              </Button>
              <Button onClick={handleExportExcel} className="flex items-center gap-2" disabled={loading}>
                <FileSpreadsheet className="w-4 h-4" />
                Export Excel
              </Button>
              <Button onClick={handleExportReport} variant="outline" className="flex items-center gap-2" disabled={loading}>
                <Download className="w-4 h-4" />
                Export CSV
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {loading ? (
        <Card className="border-2">
          <CardContent className="py-12 text-center text-muted-foreground">
            Loading report data...
          </CardContent>
        </Card>
      ) : attendance.length === 0 ? (
        <Card className="border-2">
          <CardContent className="py-12 text-center text-muted-foreground">
            📊 No attendance data found for the selected date range.
            <br />
            <span className="text-sm">Mark attendance first to see reports.</span>
          </CardContent>
        </Card>
      ) : (
        <>
          {/* Debug Info (remove in production) */}
          {process.env.NODE_ENV === 'development' && (
            <Card className="border-2 bg-yellow-50">
              <CardContent className="py-4">
                <div className="text-sm text-yellow-800">
                  <strong>Debug Info:</strong> Total Students: {students.length}, Students with Attendance: {stats.totalStudentsWithAttendance}, Attendance Records: {attendance.length}
                  <br />
                  <strong>Date Range (Ethiopian):</strong> {startDate} to {endDate}
                  <br />
                  <strong>Ethiopian Display:</strong> {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(startDate), true)} to {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(endDate), true)}
                  <br />
                  <strong>Statistics:</strong> Present: {stats.presentCount}, Absent: {stats.absentCount}, Late: {stats.lateCount}, Permission: {stats.permissionCount}
                </div>
              </CardContent>
            </Card>
          )}
          
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            <Card 
              className={`border-2 cursor-pointer transition-all hover:shadow-lg ${selectedFilter === 'all' ? 'ring-2 ring-primary' : ''}`}
              onClick={() => setSelectedFilter('all')}
            >
              <CardContent className="pt-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-foreground">{stats.totalRecords}</div>
                  <p className="text-xs text-muted-foreground mt-2">Total Students</p>
                  <p className="text-xs text-muted-foreground">({stats.totalStudentsWithAttendance} with attendance)</p>
                </div>
              </CardContent>
            </Card>
            <Card 
              className={`border-2 cursor-pointer transition-all hover:shadow-lg ${selectedFilter === 'present' ? 'ring-2 ring-green-600' : ''}`}
              onClick={() => setSelectedFilter('present')}
            >
              <CardContent className="pt-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">{stats.presentCount}</div>
                  <p className="text-xs text-muted-foreground mt-2">Present</p>
                </div>
              </CardContent>
            </Card>
            <Card 
              className={`border-2 cursor-pointer transition-all hover:shadow-lg ${selectedFilter === 'absent' ? 'ring-2 ring-red-600' : ''}`}
              onClick={() => setSelectedFilter('absent')}
            >
              <CardContent className="pt-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600">{stats.absentCount}</div>
                  <p className="text-xs text-muted-foreground mt-2">Absent</p>
                </div>
              </CardContent>
            </Card>
            <Card 
              className={`border-2 cursor-pointer transition-all hover:shadow-lg ${selectedFilter === 'late' ? 'ring-2 ring-yellow-600' : ''}`}
              onClick={() => setSelectedFilter('late')}
            >
              <CardContent className="pt-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-yellow-600">{stats.lateCount}</div>
                  <p className="text-xs text-muted-foreground mt-2">Late</p>
                </div>
              </CardContent>
            </Card>
            <Card 
              className={`border-2 cursor-pointer transition-all hover:shadow-lg ${selectedFilter === 'permission' ? 'ring-2 ring-blue-600' : ''}`}
              onClick={() => setSelectedFilter('permission')}
            >
              <CardContent className="pt-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{stats.permissionCount}</div>
                  <p className="text-xs text-muted-foreground mt-2">Permission</p>
                </div>
              </CardContent>
            </Card>
          </div>



          {/* Filtered Student List */}
          {stats.studentStats.length > 0 ? (
            <Card className="border-2">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle>
                      {selectedFilter === 'all' && 'All Students'}
                      {selectedFilter === 'present' && 'Present Students'}
                      {selectedFilter === 'absent' && 'Absent Students'}
                      {selectedFilter === 'late' && 'Late Students'}
                      {selectedFilter === 'permission' && 'Students with Permission'}
                    </CardTitle>
                    {selectedFilter !== 'all' && (
                      <CardDescription>
                        Filtered by {selectedFilter} status
                      </CardDescription>
                    )}
                  </div>
                  {selectedFilter !== 'all' && (
                    <Button 
                      variant="outline" 
                      size="sm"
                      onClick={() => setSelectedFilter('all')}
                      className="flex items-center gap-2"
                    >
                      <X className="w-4 h-4" />
                      Clear Filter
                    </Button>
                  )}
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-3 max-h-96 overflow-y-auto">
                  {stats.studentStats
                    .filter(student => {
                      if (selectedFilter === 'all') return true;
                      if (selectedFilter === 'present') return student.present > 0;
                      if (selectedFilter === 'absent') return student.absent > 0;
                      if (selectedFilter === 'late') return student.late > 0;
                      if (selectedFilter === 'permission') return student.permission > 0;
                      return true;
                    })
                    .sort((a, b) => {
                      if (selectedFilter === 'all') return b.attendanceRate - a.attendanceRate;
                      if (selectedFilter === 'present') return b.present - a.present;
                      if (selectedFilter === 'absent') return b.absent - a.absent;
                      if (selectedFilter === 'late') return b.late - a.late;
                      if (selectedFilter === 'permission') return b.permission - a.permission;
                      return 0;
                    })
                    .map((student) => (
                      <div key={student.id} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg hover:bg-muted/70 transition-colors">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{student.full_name}</p>
                          <p className="text-xs text-muted-foreground">ID: {student.id} • {student.class}</p>
                        </div>
                        <div className="flex items-center gap-4">
                          <div className="text-right text-xs space-y-1">
                            <p className="font-semibold text-sm">{student.attendanceRate}%</p>
                            <div className="flex gap-2 text-xs">
                              <span className="text-green-600">P: {student.present}</span>
                              <span className="text-red-600">A: {student.absent}</span>
                              <span className="text-yellow-600">L: {student.late}</span>
                              <span className="text-blue-600">Pr: {student.permission}</span>
                            </div>
                          </div>
                          <div className="w-24 bg-background rounded-full h-2.5">
                            <div 
                              className={`h-2.5 rounded-full ${
                                student.attendanceRate >= 80 ? 'bg-green-600' :
                                student.attendanceRate >= 60 ? 'bg-yellow-600' :
                                'bg-red-600'
                              }`}
                              style={{ width: `${student.attendanceRate}%` }}
                            />
                          </div>
                        </div>
                      </div>
                    ))}
                  {stats.studentStats.filter(student => {
                    if (selectedFilter === 'all') return true;
                    if (selectedFilter === 'present') return student.present > 0;
                    if (selectedFilter === 'absent') return student.absent > 0;
                    if (selectedFilter === 'late') return student.late > 0;
                    if (selectedFilter === 'permission') return student.permission > 0;
                    return true;
                  }).length === 0 && (
                    <div className="text-center py-8 text-muted-foreground">
                      No students found with {selectedFilter} status
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          ) : (
            <Card className="border-2">
              <CardContent className="py-12 text-center text-muted-foreground">
                📊 All {students.length} students are shown below.
                <br />
                <span className="text-sm">
                  Students with attendance in date range: {stats.totalStudentsWithAttendance} | 
                  Total attendance records: {attendance.length}
                </span>
              </CardContent>
            </Card>
          )}
        </>
      )}
    </div>
  );
}
