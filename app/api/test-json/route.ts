import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const serviceAccountKeyRaw = process.env.GOOGLE_SERVICE_ACCOUNT_KEY;
    
    if (!serviceAccountKeyRaw) {
      return NextResponse.json({
        success: false,
        error: 'GOOGLE_SERVICE_ACCOUNT_KEY is missing'
      });
    }

    // Test JSON parsing
    let serviceAccountKey;
    try {
      serviceAccountKey = JSON.parse(serviceAccountKeyRaw);
    } catch (parseError: any) {
      return NextResponse.json({
        success: false,
        error: 'JSON parsing failed',
        details: parseError.message,
        jsonPreview: serviceAccountKeyRaw.substring(0, 100) + '...'
      });
    }

    // Check required fields
    const requiredFields = ['type', 'project_id', 'private_key_id', 'private_key', 'client_email', 'client_id'];
    const fieldStatus = {};
    
    requiredFields.forEach(field => {
      fieldStatus[field] = serviceAccountKey[field] ? 'Present' : 'Missing';
    });

    return NextResponse.json({
      success: true,
      message: 'JSON parsing successful',
      fields: fieldStatus,
      serviceAccountEmail: serviceAccountKey.client_email,
      projectId: serviceAccountKey.project_id,
      keyType: serviceAccountKey.type
    });

  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}