import { NextResponse } from 'next/server';

export async function POST() {
  try {
    // In a real app, you would clear session/token here
    // For now, we'll just return success
    return NextResponse.json({
      success: true,
      message: 'Logout successful'
    });
  } catch (error: any) {
    console.error('Logout error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Logout failed' },
      { status: 500 }
    );
  }
}