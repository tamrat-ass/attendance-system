// Helper function to log admin actions
export async function logAdminAction(
  userId: number,
  username: string,
  action: string,
  targetType?: string,
  targetId?: number,
  details?: string
) {
  try {
    await fetch('/api/admin/logs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_id: userId,
        username,
        action,
        target_type: targetType,
        target_id: targetId,
        details
      })
    });
  } catch (error) {
    console.error('Failed to log action:', error);
  }
}
