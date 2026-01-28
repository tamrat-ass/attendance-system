'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Download, Calendar, Users, TrendingUp, BarChart3 } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { 
  getCurrentSimpleEthiopianDate, 
  simpleEthiopianToDbFormat,
  dbFormatToSimpleEthiopian,
  formatSimpleEthiopianDate 
} from '@/lib/simple-ethiopian-date';

interface AdminReportData {
  overall?: {
    total_students: number;
    total_classes: number;
    total_attendance_records: number;
    present_count: number;
    absent_count: number;
    late_count: number;
    permission_count: number;
    overall_attendance_rate: number;
  };
  classes?: Array<{
    class: string;
    student_count: number;
    total_records: number;
    present_count: number;
    absent_count: number;
    late_count: number;
    permission_count: number;
    attendance_rate: number;
  }>;
  trends?: Array<{
    date: string;
    present_count: number;
    absent_count: number;
    late_count: number;
    permission_count: number;
    total_records: number;
  }>;
  topPerformers?: Array<{
    id: number;
    full_name: string;
    class: string;
    total_days: number;
    present_days: number;
    attendance_rate: number;
  }>;
  needsAttention?: Array<{
    id: number;
    full_name: string;
    class: string;
    phone: string;
    total_days: number;
    absent_days: number;
    late_days: number;
    attendance_rate: number;
    recent_absences: number;
  }>;
}

export default function AdminReports() {
  const [reportType, setReportType] = useState<string>('summary');
  const [startDate, setStartDate] = useState(() => {
    const currentEthDate = getCurrentSimpleEthiopianDate();
    const startEthDate = { ...currentEthDate, day: 1 };
    return simpleEthiopianToDbFormat(startEthDate);
  });
  const [endDate, setEndDate] = useState(() => {
    const currentEthDate = getCurrentSimpleEthiopianDate();
    return simpleEthiopianToDbFormat(currentEthDate);
  });
  const [classFilter, setClassFilter] = useState<string>('');
  const [reportData, setReportData] = useState<AdminReportData>({});
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const fetchReport = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        type: reportType,
        start_date: startDate,
        end_date: endDate,
      });
      
      if (classFilter) {
        params.append('class', classFilter);
      }

      const response = await fetch(`/api/admin/reports?${params}`);
      const data = await response.json();

      if (response.ok && data.success) {
        setReportData(data.data);
      } else {
        throw new Error(data.message || 'Failed to fetch report');
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: `Failed to load report: ${error.message}`,
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReport();
  }, [reportType, startDate, endDate, classFilter]);

  const exportReport = () => {
    if (!reportData || Object.keys(reportData).length === 0) {
      toast({
        title: "No data",
        description: "No report data to export",
        variant: "destructive"
      });
      return;
    }

    // Create CSV content based on report type
    let csvContent = '';
    const startEthDate = formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(startDate), true);
    const endEthDate = formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(endDate), true);
    
    csvContent += `Admin Report - ${reportType.toUpperCase()}\n`;
    csvContent += `Period: ${startEthDate} to ${endEthDate}\n`;
    csvContent += `Generated: ${new Date().toLocaleString()}\n\n`;

    if (reportType === 'summary' && reportData.overall) {
      csvContent += 'Overall Statistics\n';
      csvContent += `Total Students,${reportData.overall.total_students}\n`;
      csvContent += `Total Classes,${reportData.overall.total_classes}\n`;
      csvContent += `Total Records,${reportData.overall.total_attendance_records}\n`;
      csvContent += `Present,${reportData.overall.present_count}\n`;
      csvContent += `Absent,${reportData.overall.absent_count}\n`;
      csvContent += `Late,${reportData.overall.late_count}\n`;
      csvContent += `Permission,${reportData.overall.permission_count}\n`;
      csvContent += `Overall Attendance Rate,${reportData.overall.overall_attendance_rate}%\n\n`;
      
      if (reportData.classes) {
        csvContent += 'Class Breakdown\n';
        csvContent += 'Class,Students,Records,Present,Absent,Attendance Rate\n';
        reportData.classes.forEach(cls => {
          csvContent += `${cls.class},${cls.student_count},${cls.total_records},${cls.present_count},${cls.absent_count},${cls.attendance_rate}%\n`;
        });
      }
    }

    // Download CSV
    const BOM = '\uFEFF';
    const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `admin-report-${reportType}-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();

    toast({
      title: "Success",
      description: "Report exported successfully"
    });
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">Admin Reports</h2>
          <p className="text-muted-foreground">Advanced analytics and detailed reports</p>
        </div>
        <Button onClick={exportReport} disabled={loading}>
          <Download className="w-4 h-4 mr-2" />
          Export Report
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle>Report Configuration</CardTitle>
          <CardDescription>Configure your report parameters</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="space-y-2">
              <Label htmlFor="report-type">Report Type</Label>
              <Select value={reportType} onValueChange={setReportType}>
                <SelectTrigger>
                  <SelectValue placeholder="Select report type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="summary">Summary Report</SelectItem>
                  <SelectItem value="detailed">Detailed Report</SelectItem>
                  <SelectItem value="class-performance">Class Performance</SelectItem>
                  <SelectItem value="student-analytics">Student Analytics</SelectItem>
                  <SelectItem value="attendance-trends">Attendance Trends</SelectItem>
                  <SelectItem value="user-activity">User Activity</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="start-date">Start Date</Label>
              <Input
                id="start-date"
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                Ethiopian: {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(startDate), true)}
              </p>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="end-date">End Date</Label>
              <Input
                id="end-date"
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                Ethiopian: {formatSimpleEthiopianDate(dbFormatToSimpleEthiopian(endDate), true)}
              </p>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="class-filter">Class Filter (Optional)</Label>
              <Input
                id="class-filter"
                placeholder="e.g., Grade 10A"
                value={classFilter}
                onChange={(e) => setClassFilter(e.target.value)}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Report Content */}
      {loading ? (
        <Card>
          <CardContent className="py-12 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
            <p>Loading report data...</p>
          </CardContent>
        </Card>
      ) : (
        <Tabs value={reportType} onValueChange={setReportType} className="space-y-4">
          <TabsList className="grid w-full grid-cols-6">
            <TabsTrigger value="summary">Summary</TabsTrigger>
            <TabsTrigger value="detailed">Detailed</TabsTrigger>
            <TabsTrigger value="class-performance">Classes</TabsTrigger>
            <TabsTrigger value="student-analytics">Analytics</TabsTrigger>
            <TabsTrigger value="attendance-trends">Trends</TabsTrigger>
            <TabsTrigger value="user-activity">Activity</TabsTrigger>
          </TabsList>

          <TabsContent value="summary">
            {reportData.overall && (
              <div className="space-y-6">
                {/* Overall Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <Card>
                    <CardContent className="pt-6">
                      <div className="flex items-center space-x-2">
                        <Users className="w-4 h-4 text-blue-600" />
                        <div>
                          <p className="text-sm font-medium text-muted-foreground">Total Students</p>
                          <p className="text-2xl font-bold">{reportData.overall.total_students}</p>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                  
                  <Card>
                    <CardContent className="pt-6">
                      <div className="flex items-center space-x-2">
                        <Calendar className="w-4 h-4 text-green-600" />
                        <div>
                          <p className="text-sm font-medium text-muted-foreground">Total Records</p>
                          <p className="text-2xl font-bold">{reportData.overall.total_attendance_records}</p>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                  
                  <Card>
                    <CardContent className="pt-6">
                      <div className="flex items-center space-x-2">
                        <TrendingUp className="w-4 h-4 text-purple-600" />
                        <div>
                          <p className="text-sm font-medium text-muted-foreground">Attendance Rate</p>
                          <p className="text-2xl font-bold">{reportData.overall.overall_attendance_rate}%</p>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                  
                  <Card>
                    <CardContent className="pt-6">
                      <div className="flex items-center space-x-2">
                        <BarChart3 className="w-4 h-4 text-orange-600" />
                        <div>
                          <p className="text-sm font-medium text-muted-foreground">Total Classes</p>
                          <p className="text-2xl font-bold">{reportData.overall.total_classes}</p>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </div>

                {/* Class Breakdown */}
                {reportData.classes && reportData.classes.length > 0 && (
                  <Card>
                    <CardHeader>
                      <CardTitle>Class Performance</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        {reportData.classes.map((cls, index) => (
                          <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                            <div>
                              <h4 className="font-medium">{cls.class}</h4>
                              <p className="text-sm text-muted-foreground">
                                {cls.student_count} students • {cls.total_records} records
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="text-lg font-bold text-green-600">{cls.attendance_rate}%</p>
                              <p className="text-sm text-muted-foreground">
                                {cls.present_count}P / {cls.late_count}L / {cls.permission_count}Pr / {cls.absent_count}A
                              </p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>
                )}
              </div>
            )}
          </TabsContent>

          <TabsContent value="detailed">
            <Card>
              <CardContent className="py-12 text-center text-muted-foreground">
                <BarChart3 className="w-12 h-12 mx-auto mb-4" />
                <p>Detailed report view will show individual student performance data.</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="class-performance">
            <Card>
              <CardContent className="py-12 text-center text-muted-foreground">
                <Users className="w-12 h-12 mx-auto mb-4" />
                <p>Class performance comparison and analytics.</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="student-analytics">
            {reportData.topPerformers && reportData.needsAttention && (
              <div className="space-y-6">
                {/* Top Performers */}
                <Card>
                  <CardHeader>
                    <CardTitle>Top Performers</CardTitle>
                    <CardDescription>Students with excellent attendance</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {reportData.topPerformers.map((student, index) => (
                        <div key={student.id} className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                          <div>
                            <p className="font-medium">{student.full_name}</p>
                            <p className="text-sm text-muted-foreground">{student.class}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-lg font-bold text-green-600">{student.attendance_rate}%</p>
                            <p className="text-sm text-muted-foreground">{student.present_days}/{student.total_days} days</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                {/* Students Needing Attention */}
                <Card>
                  <CardHeader>
                    <CardTitle>Students Needing Attention</CardTitle>
                    <CardDescription>Students with poor attendance or recent absences</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {reportData.needsAttention.map((student, index) => (
                        <div key={student.id} className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
                          <div>
                            <p className="font-medium">{student.full_name}</p>
                            <p className="text-sm text-muted-foreground">{student.class} • {student.phone}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-lg font-bold text-red-600">{student.attendance_rate}%</p>
                            <p className="text-sm text-muted-foreground">
                              {student.recent_absences} recent absences
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}
          </TabsContent>

          <TabsContent value="attendance-trends">
            <Card>
              <CardContent className="py-12 text-center text-muted-foreground">
                <TrendingUp className="w-12 h-12 mx-auto mb-4" />
                <p>Attendance trends and patterns over time.</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="user-activity">
            <Card>
              <CardContent className="py-12 text-center text-muted-foreground">
                <Calendar className="w-12 h-12 mx-auto mb-4" />
                <p>User activity logs and system usage statistics.</p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}