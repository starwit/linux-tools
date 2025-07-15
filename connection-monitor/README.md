# Connection Monitor

A bash script to monitor network connectivity using configurable check methods (ICMP, HTTP).

## Features

- Configurable check interval
- Multiple connectivity check methods (ICMP ping, HTTP requests)
- Multiple targets for each check method
- Detailed logging of each check
- Outage tracking and reporting
- Colored console output
- Machine-parsable log format

## Installation

1. Clone the repository
2. Make the script executable:

```bash
chmod +x connection-monitor.sh
```

## Usage

Basic usage with default settings (ping 8.8.8.8 every 60 seconds):

```bash
./connection-monitor.sh
```

Advanced usage with custom configuration:

```bash
./connection-monitor.sh --interval 30 \
    --ping 8.8.8.8 \
    --ping 1.1.1.1 \
    --http google.com \
    --http https://example.com \
    --ping-count 3 \
    --ping-timeout 2 \
    --http-timeout 5 \
    --log-dir /path/to/logs \
    --verbose
```

## Command-line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-i, --interval` | Check interval in seconds | 60 |
| `-d, --log-dir` | Directory to store logs | ./logs |
| `-p, --ping` | Add an ICMP ping target (can be used multiple times) | 8.8.8.8 (if no targets specified) |
| `-h, --http` | Add an HTTP target (can be used multiple times) | none |
| `--ping-count` | Number of ICMP pings | 3 |
| `--ping-timeout` | ICMP ping timeout in seconds | 2 |
| `--http-timeout` | HTTP request timeout in seconds | 5 |
| `-v, --verbose` | Display verbose output | off |
| `--help` | Display help message | - |

## Logs

The script creates several log files in the specified log directory, with each filename prefixed by the start timestamp (YYYYMMDDHHMMSS):

- `YYYYMMDDHHMMSS_connection.log` - General connection status log (up/down)
- `YYYYMMDDHHMMSS_outage.log` - Connection outage events (outage_start, restored)
- `YYYYMMDDHHMMSS_icmp_{target}.log` - Individual ICMP check results with latency
- `YYYYMMDDHHMMSS_http_{target}.log` - Individual HTTP check results with response time

### Log Format

All logs are in CSV format with a timestamp prefix.

Examples:

```
# ICMP/HTTP target log
2023-06-01 12:34:56,success,45.3
2023-06-01 12:35:56,failure,timeout

# General connection log
2023-06-01 12:34:56,up
2023-06-01 12:35:56,down

# Outage log
2023-06-01 12:35:56,outage_start,0
2023-06-01 12:40:56,restored,300
```

## Examples

1. Monitor connectivity to multiple DNS servers and websites:

```bash
./connection-monitor.sh --ping 8.8.8.8 --ping 1.1.1.1 --http google.com
```

2. HTTP-only monitoring:

```bash
./connection-monitor.sh --http example.com --http https://api.github.com --http-timeout 3
```

3. Quick check with low timeouts:

```bash
./connection-monitor.sh --ping 8.8.8.8 --ping-timeout 1 --interval 15
```
