#!/usr/bin/env python3
import argparse
import os
import sys
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from rich.console import Console
from rich.table import Table
from tqdm import tqdm
from datetime import datetime, timedelta, timezone

API_URL = "https://api.github.com"
console = Console()

def get_repos(org, token):
    repos = []
    page = 1
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github.v3+json"}
    while True:
        resp = requests.get(f"{API_URL}/orgs/{org}/repos", headers=headers, params={"per_page": 100, "page": page, "sort": "updated", "direction": "desc"})
        if resp.status_code != 200:
            console.print(f"[red]Error fetching repos: {resp.status_code} {resp.text}[/red]")
            sys.exit(1)
        data = resp.json()
        if not data:
            break
        repos.extend(data)
        page += 1
    return repos

def get_runs_by_status(org, repo, status, token, completed_since_hours=None):
    """Get runs for a single repository and status"""
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github.v3+json"}
    params = {"status": status}
    
    # For completed jobs, filter to specified hours
    if status == "completed" and completed_since_hours is not None:
        since_time = (datetime.now(timezone.utc) - timedelta(hours=completed_since_hours)).isoformat()
        params["created"] = f">={since_time}"
    
    resp = requests.get(f"{API_URL}/repos/{org}/{repo}/actions/runs", headers=headers, params=params)
    if resp.status_code != 200:
        console.print(f"[yellow]Warning: repo {repo} status {status} returned {resp.status_code}[/yellow]")
        return []
    return resp.json().get("workflow_runs", [])

def fetch_repo_status_runs(org, repo, status, token, completed_since_hours=None):
    """Wrapper function for parallel execution of single status request"""
    runs = get_runs_by_status(org, repo, status, token, completed_since_hours)
    return (repo, status), runs

def colorize_status(status):
    """Apply color styling to status based on its value"""
    if status == "completed":
        return f"[bright_black]{status}[/bright_black]"
    else:
        return f"[bright_blue]{status}[/bright_blue]"

def colorize_conclusion(conclusion):
    """Apply color styling to conclusion based on its value"""
    if conclusion == "success":
        return f"[green]{conclusion}[/green]"
    elif conclusion == "failure":
        return f"[red]{conclusion}[/red]"
    elif conclusion == "cancelled":
        return f"[bright_black]{conclusion}[/bright_black]"
    else:
        return conclusion

def display_runs(all_runs, show_urls=False):
    table = Table(title="Active GitHub Actions Runs")
    table.add_column("Repo", style="cyan", no_wrap=True)
    table.add_column("Started At", style="yellow")
    table.add_column("Title", style="blue", max_width=40)
    table.add_column("Status")
    table.add_column("Conclusion", justify="center")
    if show_urls:
        table.add_column("URL", style="dim", no_wrap=True)

    # Flatten all runs and sort by started_at
    all_runs_flat = []
    for repo, runs in all_runs.items():
        for run in runs:
            all_runs_flat.append((repo, run))
    
    # Sort by run_started_at (ascending order)
    all_runs_flat.sort(key=lambda x: x[1].get("run_started_at", ""))

    for repo, run in all_runs_flat:
        title = run.get("display_title", "")
        # Truncate title if too long
        if len(title) > 37:
            title = title[:34] + "..."
        
        conclusion = run.get("conclusion") or "-"
        status = run["status"]
        started_at = run.get("run_started_at", "")
        # Format started_at to show just date and time
        if started_at:
            try:
                dt = datetime.fromisoformat(started_at).astimezone()
                started_at = dt.strftime("%d. %b %H:%M")
            except:
                pass
        
        row_data = [
            repo, 
            started_at,
            title, 
            colorize_status(status),
            colorize_conclusion(conclusion)
        ]
        
        if show_urls:
            url = run.get("html_url", "")
            row_data.append(url)
        
        table.add_row(*row_data)
    console.print(table)

def main():
    parser = argparse.ArgumentParser(description="Monitor pending/in-progress GitHub Actions runs for an org")
    parser.add_argument("org", help="GitHub organization name")
    parser.add_argument("-t", "--token", help="GitHub access token (or set GITHUB_TOKEN)", default=os.getenv("GITHUB_TOKEN"))
    parser.add_argument("--include-completed-since-hours", type=int, default=8, help="Also show completed jobs from the last N hours")
    parser.add_argument("--fetch-all-repos", action='store_true', help="Do not filter repos for `pushed_at` and query all repos (will take longer)")
    parser.add_argument("--show-urls", action='store_true', help="Show the GitHub Actions run URLs in the table")
    args = parser.parse_args()

    if not args.token:
        console.print("[red]Error: Access token must be provided via --token or GITHUB_TOKEN env var[/red]")
        sys.exit(1)

    repos = get_repos(args.org, args.token)
    if args.fetch_all_repos:
        repo_names = [r["name"] for r in repos]
    else:
        repo_names = [r["name"] for r in repos if datetime.fromisoformat(r["pushed_at"]) > datetime.now().astimezone() - timedelta(hours=args.include_completed_since_hours*2)]

    console.print(f"Found [green]{len(repo_names)}[/green] repos in org '{args.org}'.")

    all_runs = {}
    
    # Create all repo+status combinations for parallel requests
    statuses = ["in_progress", "queued"]
    if args.include_completed_since_hours is not None:
        statuses.append("completed")
    
    requests_to_make = [
        (repo, status) for repo in repo_names 
        for status in statuses
    ]
    
    # Use ThreadPoolExecutor for parallel requests
    with ThreadPoolExecutor(max_workers=40) as executor:
        # Submit all repo+status requests
        future_to_request = {
            executor.submit(fetch_repo_status_runs, args.org, repo, status, args.token, args.include_completed_since_hours): (repo, status)
            for repo, status in requests_to_make
        }
        
        # Collect results with progress bar
        for future in tqdm(as_completed(future_to_request), total=len(requests_to_make), desc="Polling repos", unit="request", leave=False):
            (repo, status), runs = future.result()
            if runs:
                if repo not in all_runs:
                    all_runs[repo] = []
                all_runs[repo].extend(runs)
    
    display_runs(all_runs, show_urls=args.show_urls)

if __name__ == "__main__":
    main()
