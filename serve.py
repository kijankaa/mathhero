"""
Lokalny serwer dla MathHero — dodaje nagłówki COOP/COEP wymagane przez Godot HTML5.
Uruchom: python serve.py
Dostęp z iPada: http://192.168.100.4:8080
"""
import http.server
import os

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), "docs")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def log_message(self, format, *args):
        print(f"  {args[0]} {args[1]}")


if __name__ == "__main__":
    os.chdir(DIRECTORY)
    with http.server.HTTPServer(("0.0.0.0", PORT), Handler) as httpd:
        print(f"MathHero serwer uruchomiony")
        print(f"  PC:   http://localhost:{PORT}")
        print(f"  iPad: http://192.168.100.4:{PORT}")
        print(f"  (Ctrl+C aby zatrzymac)")
        httpd.serve_forever()
