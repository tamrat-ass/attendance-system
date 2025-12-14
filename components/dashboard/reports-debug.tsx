'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

export default function ReportsDebug() {
  const [debugInfo, setDebugInfo] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const runDiagnostics = async () => {
    setLoading(true);
    const results: any = {};

    try {
      // Test students API
      console.log('Testing students API...');
      const studentsRes = await fetch('/api/students?limit=10');
      const studentsData = await studentsRes.json();
      results.students = {
        status: studentsRes.status,
        ok: studentsRes.ok,
        data: studentsData,
        count: studentsData.data?.length || 0
      };

      // Test attendance API
      console.log('Testing attendance API...');
      const attendanceRes = await fetch('/api/attendance?limit=10');
      const attendanceData = await attendanceRes.json();
      results.attendance = {
        status: attendanceRes.status,
        ok: attendanceRes.ok,
        data: attendanceData,
        count: attendanceData.data?.length || 0
      };

      // Test attendance with Ethiopian date range
      const currentEthDate = { year: 2018, month: 4, day: 5 }; // Example Ethiopian date
      const startEthDate = { year: 2018, month: 4, day: 1 };
      const todayEth = `${currentEthDate.year.toString().padStart(4, '0')}-${currentEthDate.month.toString().padStart(2, '0')}-${currentEthDate.day.toString().padStart(2, '0')}`;
      const startEth = `${startEthDate.year.toString().padStart(4, '0')}-${startEthDate.month.toString().padStart(2, '0')}-${startEthDate.day.toString().padStart(2, '0')}`;
      console.log('Testing attendance with Ethiopian date range...');
      const attendanceRangeRes = await fetch(`/api/attendance?start_date=${startEth}&end_date=${todayEth}`);
      const attendanceRangeData = await attendanceRangeRes.json();
      results.attendanceRange = {
        status: attendanceRangeRes.status,
        ok: attendanceRangeRes.ok,
        data: attendanceRangeData,
        count: attendanceRangeData.data?.length || 0,
        dateRange: `${startEth} to ${todayEth} (Ethiopian)`
      };

    } catch (error: any) {
      results.error = error.message;
    }

    setDebugInfo(results);
    setLoading(false);
  };

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Reports Debug Tool</CardTitle>
        </CardHeader>
        <CardContent>
          <Button onClick={runDiagnostics} disabled={loading}>
            {loading ? 'Running Diagnostics...' : 'Run Diagnostics'}
          </Button>
          
          {debugInfo && (
            <div className="mt-4 space-y-4">
              <div className="bg-gray-100 p-4 rounded">
                <h3 className="font-bold">Students API Test:</h3>
                <p>Status: {debugInfo.students?.status}</p>
                <p>OK: {debugInfo.students?.ok ? 'Yes' : 'No'}</p>
                <p>Count: {debugInfo.students?.count}</p>
                <details>
                  <summary>Raw Data</summary>
                  <pre className="text-xs overflow-auto">
                    {JSON.stringify(debugInfo.students?.data, null, 2)}
                  </pre>
                </details>
              </div>

              <div className="bg-gray-100 p-4 rounded">
                <h3 className="font-bold">Attendance API Test:</h3>
                <p>Status: {debugInfo.attendance?.status}</p>
                <p>OK: {debugInfo.attendance?.ok ? 'Yes' : 'No'}</p>
                <p>Count: {debugInfo.attendance?.count}</p>
                <details>
                  <summary>Raw Data</summary>
                  <pre className="text-xs overflow-auto">
                    {JSON.stringify(debugInfo.attendance?.data, null, 2)}
                  </pre>
                </details>
              </div>

              <div className="bg-gray-100 p-4 rounded">
                <h3 className="font-bold">Attendance Range Test:</h3>
                <p>Date Range: {debugInfo.attendanceRange?.dateRange}</p>
                <p>Status: {debugInfo.attendanceRange?.status}</p>
                <p>OK: {debugInfo.attendanceRange?.ok ? 'Yes' : 'No'}</p>
                <p>Count: {debugInfo.attendanceRange?.count}</p>
                <details>
                  <summary>Raw Data</summary>
                  <pre className="text-xs overflow-auto">
                    {JSON.stringify(debugInfo.attendanceRange?.data, null, 2)}
                  </pre>
                </details>
              </div>

              {debugInfo.error && (
                <div className="bg-red-100 p-4 rounded">
                  <h3 className="font-bold text-red-600">Error:</h3>
                  <p>{debugInfo.error}</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}