'use client';

import { useState, useEffect } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import StudentManagement from './student-management';
import AttendanceMarking from './attendance-marking';
import Reports from './reports';
import AdminPanel from './admin-panel';
import Header from './header';

interface DashboardProps {
  onLogout: () => void;
}

interface UserPermissions {
  can_manage_students?: boolean;
  can_mark_attendance?: boolean;
  can_view_reports?: boolean;
  can_export_data?: boolean;
  can_manage_users?: boolean;
}

// Dashboard component
export default function Dashboard({ onLogout }: DashboardProps) {
  const [activeTab, setActiveTab] = useState('attendance');
  const [permissions, setPermissions] = useState<UserPermissions>({
    can_manage_students: true,
    can_mark_attendance: true,
    can_view_reports: true,
    can_export_data: true,
    can_manage_users: true
  });

  // Function to refresh permissions from server
  const refreshPermissions = async () => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        const response = await fetch('/api/auth/refresh-permissions', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: user.id })
        });

        if (response.ok) {
          const data = await response.json();
          if (data.success) {
            // Update localStorage with fresh permissions
            localStorage.setItem('user', JSON.stringify(data.user));
            
            // Update state
            setPermissions({
              can_manage_students: data.user.can_manage_students ?? true,
              can_mark_attendance: data.user.can_mark_attendance ?? true,
              can_view_reports: data.user.can_view_reports ?? true,
              can_export_data: data.user.can_export_data ?? true,
              can_manage_users: data.user.can_manage_users ?? true
            });
          }
        }
      } catch (e) {
        console.error('Error refreshing permissions:', e);
      }
    }
  };

  // Load user permissions from localStorage
  useEffect(() => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        setPermissions({
          can_manage_students: user.can_manage_students ?? true,
          can_mark_attendance: user.can_mark_attendance ?? true,
          can_view_reports: user.can_view_reports ?? true,
          can_export_data: user.can_export_data ?? true,
          can_manage_users: user.can_manage_users ?? true
        });

        // Set default tab based on permissions
        if (user.can_mark_attendance) {
          setActiveTab('attendance');
        } else if (user.can_manage_students) {
          setActiveTab('students');
        } else if (user.can_view_reports) {
          setActiveTab('reports');
        } else if (user.can_manage_users) {
          setActiveTab('admin');
        }
      } catch (e) {
        console.error('Error parsing user data:', e);
      }
    }

    // Refresh permissions every 5 seconds
    const interval = setInterval(refreshPermissions, 5000);
    
    return () => clearInterval(interval);
  }, []);
// Render dashboard with tabs for attendance, students, and reports
  return (
    <div className="min-h-screen bg-background">
      <Header onLogout={onLogout} />
      
      <main className="max-w-7xl mx-auto p-6">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className={`grid w-full mb-6`} style={{ gridTemplateColumns: `repeat(${[permissions.can_mark_attendance, permissions.can_manage_students, permissions.can_view_reports, permissions.can_manage_users].filter(Boolean).length}, 1fr)` }}>
            {permissions.can_mark_attendance && (
              <TabsTrigger value="attendance" className="flex items-center gap-2">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
                </svg>
                Mark Attendance
              </TabsTrigger>
            )}
            {permissions.can_manage_students && (
              <TabsTrigger value="students" className="flex items-center gap-2">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 12H9m6 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Students
              </TabsTrigger>
            )}
            {permissions.can_view_reports && (
              <TabsTrigger value="reports" className="flex items-center gap-2">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                Reports
              </TabsTrigger>
            )}
            {permissions.can_manage_users && (
              <TabsTrigger value="admin" className="flex items-center gap-2">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                Admin Panel
              </TabsTrigger>
            )}
          </TabsList>
{/* Tab contents */}
          {permissions.can_mark_attendance && (
            <TabsContent value="attendance" className="space-y-4">
              <AttendanceMarking />
            </TabsContent>
          )}
{/* Student Management Tab */}
          {permissions.can_manage_students && (
            <TabsContent value="students" className="space-y-4">
              <StudentManagement />
            </TabsContent>
          )}
{/* Reports Tab */}
          {permissions.can_view_reports && (
            <TabsContent value="reports" className="space-y-4">
              <Reports />
            </TabsContent>
          )}
{/* Admin Panel Tab */}
          {permissions.can_manage_users && (
            <TabsContent value="admin" className="space-y-4">
              <AdminPanel />
            </TabsContent>
          )}
        </Tabs>
      </main>
    </div>
  );
}
