'use client';

import { useMemo, useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { SimpleEthiopianDateInput } from '@/components/ui/simple-ethiopian-date-input';
import { Download, X } from 'lucide-react';
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

  const [startDate, setStartDate] = useState(() => {
    // 30 days ago in Ethiopian calendar
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const startEthDate = { ...currentEthDate, day: Math.max(1, currentEthDate.day - 30) };
    if (startEthDate.day > currentEthDate.day) {
      startEthDate.month = Math.max(1, startEthDate.month - 1);
      if (startEthDate.month === 13) {
        startEthDate.day = Math.min(6, startEthDate.day);
      } else {
        startEthDate.day = Math.min(30, startEthDate.day);
      }
    }
    return simpleEthiopianToGregorian(startEthDate);
  });
  const [endDate, setEndDate] = useState(() => {
    const currentEthDate = getCurrentSimpleEthiopianDate();
    return simpleEthiopianToGregorian(currentEthDate);
  });

  // Fetch students and attendance
  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch students
      const studentsRes = await fetch('/api/students');
      const studentsData = await studentsRes.json();
      
      // Fetch attendance
      const attendanceRes = await fetch(`/api/attendance?start_date=${startDate}&end_date=${endDate}`);
      const attendanceData = await attendanceRes.json();

      if (studentsRes.ok) {
        setStudents(studentsData.data || []);
      }

      if (attendanceRes.ok) {
        setAttendance(attendanceData.data || []);
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: "Failed to load report data",
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
    if (attendance.length === 0) {
      return {
        totalRecords: 0,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0,
        permissionCount: 0,
        dateChartData: [],
        pieData: [],
        studentStats: [],
        classStats: []
      };
    }

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
        const ethDate = gregorianToSimpleEthiopian(date);
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

    // Calculate student stats
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
    }).filter(s => s.total > 0); // Only show students with attendance records

    const classStats = Object.entries(byClass).map(([className, stats]) => ({
      class: className,
      ...stats
    }));

    return {
      totalRecords: students.length,
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



  const handleExportReport = () => {
    if (stats.studentStats.length === 0) {
      toast({
        title: "No data",
        description: "No attendance data to export",
        variant: "destructive"
      });
      return;
    }

    const data = stats.studentStats.map(student => ({
      'Student ID': student.id,
      'Name': student.full_name,
      'Class': student.class,
      'Phone': student.phone,
      'Total Days': student.total,
      'Present': student.present,
      'Absent': student.absent,
      'Late': student.late,
      'Permission': student.permission,
      'Attendance Rate': `${student.attendanceRate}%`
    }));

    const headers = Object.keys(data[0]);
    const startEthDate = formatSimpleEthiopianDate(gregorianToSimpleEthiopian(startDate), true);
    const endEthDate = formatSimpleEthiopianDate(gregorianToSimpleEthiopian(endDate), true);
    
    const csv = [
      `Attendance Report (${startEthDate} to ${endEthDate})`,
      '',
      headers.join(','),
      ...data.map(row => 
        headers.map(h => `"${row[h as keyof typeof row]}"`).join(',')
      )
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `attendance-report-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();

    toast({
      title: "Success",
      description: "Report exported successfully"
    });
  };

  return (
    <div className="space-y-6">
      {/* Date Range Filter */}
      <Card className="border-2">
        <CardHeader>
          <CardTitle>Report Filter</CardTitle>
          <CardDescription>Select Ethiopian date range to view attendance reports</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <SimpleEthiopianDateInput
              label="ከ ቀን (From Date)"
              value={startDate}
              onChange={setStartDate}
              useAmharic={true}
            />
            <SimpleEthiopianDateInput
              label="እስከ ቀን (To Date)"
              value={endDate}
              onChange={setEndDate}
              useAmharic={true}
            />
            <div className="flex items-end">
              <Button onClick={handleExportReport} className="w-full flex items-center gap-2" disabled={loading}>
                <Download className="w-4 h-4" />
                Export Report
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
          {stats.studentStats.length > 0 && (
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
          )}
        </>
      )}
    </div>
  );
}
