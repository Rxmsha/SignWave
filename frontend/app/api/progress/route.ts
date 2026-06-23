import { NextRequest, NextResponse } from 'next/server';

// Accounts/persistence are disabled for this demo/prototype build.
// Progress is not stored anywhere (Firebase is not configured), so these
// endpoints are no-ops that return success — this keeps the lessons/games
// flowing without auth and avoids 401/500 errors in the UI.

// GET: return an empty progress list.
export async function GET(_request: NextRequest) {
    return NextResponse.json({ success: true, data: [] });
}

// POST: pretend the progress was saved.
export async function POST(request: NextRequest) {
    let body: Record<string, unknown> = {};
    try {
        body = await request.json();
    } catch {
        // ignore malformed/empty body
    }

    return NextResponse.json({
        success: true,
        message: 'Progress not persisted (demo mode)',
        data: body,
    });
}
