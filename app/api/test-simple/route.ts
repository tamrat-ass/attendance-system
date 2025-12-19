import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // Test 1: Basic response
    console.log('🔧 Testing basic functionality...');
    
    // Test 2: Environment variables
    const envTest = {
      GOOGLE_SPREADSHEET_ID: process.env.GOOGLE_SPREADSHEET_ID ? 'Set' : 'Missing',
      GOOGLE_SERVICE_ACCOUNT_KEY: process.env.GOOGLE_SERVICE_ACCOUNT_KEY ? 'Set' : 'Missing',
    };
    
    // Test 3: Try to import googleapis
    let googleImportTest = { success: false, error: null };
    try {
      const { google } = await import('googleapis');
      googleImportTest.success = true;
      console.log('✅ googleapis import successful');
    } catch (importError: any) {
      googleImportTest.error = importError.message;
      console.log('❌ googleapis import failed:', importError.message);
    }

    return NextResponse.json({
      success: true,
      tests: {
        basic: 'Working',
        environment: envTest,
        googleImport: googleImportTest
      },
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('❌ Simple test failed:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack?.split('\n').slice(0, 5), // First 5 lines of stack
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}