import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.getenv("PORT", "3000"))

class Handler(BaseHTTPRequestHandler):
    def _write(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path in {"/health/live", "/health/ready", "/api/v1/health"}:
            self._write(200, {"status": "ok", "service": "api", "path": self.path})
            return
        if self.path.startswith("/api/v1/admin"):
            self._write(200, {"message": "Admin placeholder API", "path": self.path})
            return
        if self.path.startswith("/api/v1") or self.path == "/":
            self._write(200, {"message": "AiClod API placeholder", "path": self.path})
            return
        self._write(404, {"error": "not_found", "path": self.path})

    def log_message(self, fmt, *args):
        return

HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
