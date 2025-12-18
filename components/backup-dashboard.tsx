'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { RefreshCw, Download, CheckCircle, XCircle, Clock } from 'lucide-react';

interface BackupLog {
  id: number;
  backup_type: string;
  status: string;
  students_count: number;
  attendance_count: number;
  error_message?: string;
  duration_ms?: number;
  created_at: string;
}

export default function BackupDashboard() {
  const [backupLogs, setBackupLogs] = useState<BackupLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Fetch backup status
  const fetchBackupStatus = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/backup?action=status');
      const data = await response.json();
      
      if (data.success) {
        setBackupLogs(data.recentBackups || []);
      } else {
        setError(data.message || 'Failed to fetch backup status');
      }
    } catch (err: any) {
      setError('Failed to fetch backup status: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Trigger manual backup
  const triggerManualBackup = async () => {
    try {
      setLoading(true);
      setError('');
      setSuccess('');
      
      const response = await fetch('/api/backup/manual', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.NEXT_PUBLIC_BACKUP_API_KEY}`,
          'Content-Type': 'application/json',
        },
      });
      
      const data = await response.json();
      
      if (data.success) {
        setSuccess('Manual backup completed successfully!');
        await fetchBackupStatus(); // Refresh the logs
      } else {
        setError(data.message || 'Manual backup failed');
      }
    } catch (err: any) {
      setError('Failed to trigger manual backup: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Setup Google Sheets
  const setupGoogleSheets = async () => {
    try {
      setLoading(true);
      setError('');
      setSuccess('');
      
      const response = await fetch('/api/backup/setup', {
        method: 'POST',
      });
      
      const data = await response.json();
      
      if (data.success) {
        setSuccess('Google Sheets setup completed successfully!');
      } else {
        setError(data.message || 'Google Sheets setup failed');
      }
    } catch (err: any) {
      setError('Failed to setup Google Sheets: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Format date
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  // Get status badge
  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'success':
        return <Badge className="bg-green-100 text-green-800"><CheckCircle className="w-3 h-3 mr-1" />Success</Badge>;
      case 'failed':
        return <Badge className="bg-red-100 text-red-800"><XCircle className="w-3 h-3 mr-1" />Failed</Badge>;
      case 'in_progress':
        return <Badge className="bg-yellow-100 text-yellow-800"><Clock className="w-3 h-3 mr-1" />In Progress</Badge>;
      default:
        return <Badge variant="secondary">{status}</Badge>;
    }
  };

  // Load data on component mount
  useEffect(() => {
    fetchBackupStatus();
  }, []);

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Download className="w-5 h-5" />
            Backup System Dashboard
          </CardTitle>
          <CardDescription>
            Monitor and manage automatic database backups to Google Sheets
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {error && (
            <Alert variant="destructive">
              <XCircle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
          
          {success && (
            <Alert className="border-green-200 bg-green-50">
              <CheckCircle className="h-4 w-4 text-green-600" />
              <AlertDescription className="text-green-800">{success}</AlertDescription>
            </Alert>
          )}

          <div className="flex gap-2 flex-wrap">
            <Button 
              onClick={fetchBackupStatus} 
              disabled={loading}
              variant="outline"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
              Refresh Status
            </Button>
            
            <Button 
              onClick={triggerManualBackup} 
              disabled={loading}
            >
              <Download className="w-4 h-4 mr-2" />
              Manual Backup
            </Button>
            
            <Button 
              onClick={setupGoogleSheets} 
              disabled={loading}
              variant="secondary"
            >
              Setup Google Sheets
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Recent Backup History</CardTitle>
          <CardDescription>
            Last 10 backup attempts with status and details
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading && backupLogs.length === 0 ? (
            <div className="text-center py-4">
              <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2" />
              Loading backup history...
            </div>
          ) : backupLogs.length === 0 ? (
            <div className="text-center py-4 text-muted-foreground">
              No backup history found
            </div>
          ) : (
            <div className="space-y-3">
              {backupLogs.map((log) => (
                <div key={log.id} className="border rounded-lg p-4 space-y-2">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      {getStatusBadge(log.status)}
                      <span className="text-sm text-muted-foreground">
                        {formatDate(log.created_at)}
                      </span>
                    </div>
                    {log.duration_ms && (
                      <span className="text-xs text-muted-foreground">
                        {log.duration_ms}ms
                      </span>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="font-medium">Students:</span> {log.students_count}
                    </div>
                    <div>
                      <span className="font-medium">Attendance:</span> {log.attendance_count}
                    </div>
                  </div>
                  
                  {log.error_message && (
                    <div className="text-sm text-red-600 bg-red-50 p-2 rounded">
                      <span className="font-medium">Error:</span> {log.error_message}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Backup Configuration</CardTitle>
          <CardDescription>
            Current backup system settings and schedule
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <span className="font-medium">Schedule:</span> Daily at 2:00 AM UTC
            </div>
            <div>
              <span className="font-medium">Students Backup:</span> Complete overwrite
            </div>
            <div>
              <span className="font-medium">Attendance Backup:</span> Incremental append
            </div>
            <div>
              <span className="font-medium">Timeout:</span> 5 minutes maximum
            </div>
          </div>
          
          <div className="pt-2 border-t">
            <p className="text-xs text-muted-foreground">
              Automatic backups run daily using Vercel Cron Jobs. 
              Manual backups can be triggered anytime using the button above.
              All backup attempts are logged for monitoring and troubleshooting.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}