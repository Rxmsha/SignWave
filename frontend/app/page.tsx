"use client";

import { useEffect } from "react";

// Accounts are disabled for this demo/prototype build.
// The root route seeds a guest identity in localStorage and sends the user
// straight into the app — no login or registration required.
export default function Home() {
  useEffect(() => {
    if (!localStorage.getItem("userId")) {
      localStorage.setItem("userId", "guest");
      localStorage.setItem("userName", "Guest");
      localStorage.setItem("username", "guest");
    }
    window.location.replace("/dashboard");
  }, []);

  return (
    <div className="flex min-h-screen items-center justify-center">
      <p className="text-muted-foreground">Loading SignWave…</p>
    </div>
  );
}
