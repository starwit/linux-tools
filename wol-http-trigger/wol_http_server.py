import argparse
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer

WOL_DEVICES = [
    ('Machine A', 'MAC_ADDRESS_A'),
    ('Machine B', 'MAC_ADDRESS_B'),
]

def generate_html():
    html_str = '''
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Wake-On-LAN</title>
        </head>
        <body>
    ''' + "".join([
        f"<p><button onclick=\"fetch('/trigger_wol/{id}')\">Power On {dev[0]}</button>"
        for id, dev in enumerate(WOL_DEVICES)
    ]) + '''
        </body>
        </html>
    '''
    return bytes(html_str, 'utf-8')

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(generate_html())
        elif self.path.startswith('/trigger_wol/'):
            dev_id = int(self.path.split('/')[-1])
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            try:
                result = subprocess.run(['wakeonlan', WOL_DEVICES[dev_id][1]], capture_output=True, text=True)
                output = result.stdout
                self.log_message(f'Successfully sent WOL trigger to {WOL_DEVICES[dev_id][0]} ({WOL_DEVICES[dev_id][1]})')
                self.wfile.write(f'System program executed successfully. Output: {output}'.encode('utf-8'))
            except Exception as e:
                self.wfile.write(f'Error executing system program: {str(e)}'.encode('utf-8'))
                self.log_error(f'Failed to send WOL trigger to {WOL_DEVICES[dev_id][0]} ({WOL_DEVICES[dev_id][1]})')
                self.log_error(str(e))
        else:
            self.send_error(404)

def main():
    parser = argparse.ArgumentParser(description='Run a web server with an endpoint to execute a system program.')
    parser.add_argument('--port', type=int, default=8000, help='Port number for the web server (default: 8000)')
    args = parser.parse_args()

    server_address = ('', args.port)
    httpd = HTTPServer(server_address, RequestHandler)
    print(f'Starting server on port {args.port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    main()

