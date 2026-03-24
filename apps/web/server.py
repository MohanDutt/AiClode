import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.getenv("PORT", "3001"))
API_BASE_URL = os.getenv("NEXT_PUBLIC_API_BASE_URL", "http://localhost:3000/api/v1")

HTML = f"""<!doctype html>
<html>
<head><title>AiClod Local Web</title></head>
<body>
  <h1>AiClod local web placeholder</h1>
  <p>API base URL: {API_BASE_URL}</p>
  <p>This placeholder exists so localhost bootstrap succeeds before the full application is implemented.</p>
</body>
</html>
"""

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = HTML.encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        return

HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
