import { NextResponse } from 'next/server';
import { google } from 'googleapis';

export async function GET() {
  try {
    console.log('🔧 Testing NEW Google Service Account Key...');
    
    // Test if we can parse the JSON
    let credentials;
    try {
      credentials = JSON.parse(
        process.env.GOOGLE_SERVICE_ACCOUNT_KEY!.replace(/\\n/g, '\n')
      );
      console.log('✅ JSON parsing successful');
      console.log('Project ID:', credentials.project_id);
      console.log('Client Email:', credentials.client_email);
    } catch (parseError: any) {
      console.error('❌ JSON parsing failed:', parseError.message);
      return NextResponse.json({
        success: false,
        error: 'JSON parsing failed',
        details: parseError.message
      }, { status: 500 });
    }
    
    // Test Google Auth
    try {
      const auth = new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/spreadsheets'],
      });
      
      const authClient = await auth.getClient();
      console.log('✅ Google Auth client created successfully');
      
      return NextResponse.json({
        success: true,
        message: 'New Google Service Account Key works!',
        projectId: credentials.project_id,
        clientEmail: credentials.client_email,
        timestamp: new Date().toISOString()
      });
      
    } catch (authError: any) {
      console.error('❌ Google Auth failed:', authError.message);
      return NextResponse.json({
        success: false,
        error: 'Google Auth failed',
        details: authError.message
      }, { status: 500 });
    }
    
  } catch (err: any) {
    console.error('❌ Test failed:', err);
    return NextResponse.json({
      success: false,
      error: err.message,
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}