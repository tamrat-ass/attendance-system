import { NextRequest, NextResponse } from 'next/server';

// Manual backup trigger with authentication
export async function POST(request: NextRequest) {
  try {
    // Simple authentication check (you can enhance this)
    const authHeader = request.headers.get('authorization');
    const expectedAuth = `Bearer ${process.env.BACKUP_API_KEY}`;
    
    if (!authHeader || authHeader !== expectedAuth) {
      return NextResponse.json({
        success: false,
        message: 'Unauthorized'
      }, { status: 401 });
    }

    console.log('🔧 Manual backup triggered');

    // Call the main backup API
    const backupResponse = await fetch(`${process.env.VERCEL_URL || 'http://localhost:3000'}/api/backup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const backupResult = await backupResponse.json();

    return NextResponse.json({
      success: true,
      message: 'Manual backup completed',
      result: backupResult
    });

  } catch (error: any) {
    console.error('❌ Manual backup failed:', error);
    
    return NextResponse.json({
      success: false,
      message: 'Manual backup failed',
      error: error.message
    }, { status: 500 });
  }
}

// GET endpoint for backup status
export async function GET(request: NextRequest) {
  try {
    const response = await fetch(`${process.env.VERCEL_URL || 'http://localhost:3000'}/api/backup?action=status`);
    const result = await response.json();

    return NextResponse.json(result);

  } catch (error: any) {
    return NextResponse.json({
      success: false,
      message: 'Failed to get backup status',
      error: error.message
    }, { status: 500 });
  }
}