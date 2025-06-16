from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        action = self.path.lstrip('/action/')
        if action == "start":
            os.system("echo Starting VM...")
        elif action == "stop":
            os.system("pkill -f qemu-system")
        elif action == "restart":
            os.system("pkill -f qemu-system && /start.sh &")
        elif action == "bridge":
            os.system("echo Set to bridge mode")
        elif action == "nat":
            os.system("echo Set to NAT mode")
        self.send_response(200)
        self.end_headers()
        self.wfile.write(f"Executed {action}".encode())

HTTPServer(('0.0.0.0', 8080), SimpleHandler).serve_forever()