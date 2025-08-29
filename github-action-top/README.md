# GitHub Action Top

A command-line tool to monitor GitHub Actions workflow runs across all repositories in an organization. Similar to the Unix `top` command, but for GitHub Actions.

## Features

- Lists all active (in-progress and queued) workflow runs across an organization
- Displays runs sorted by start time (oldest first)
- Color-coded status and conclusion columns for easy visual scanning
- Parallel API requests for fast data retrieval
- Smart repository filtering to reduce API calls

## Install dependencies

```bash
poetry install
```

## Usage

### Basic Usage

Show all active (in-progress and queued) workflow runs:

```bash
python main.py your-org-name
```

### With GitHub Token

Use a GitHub personal access token (recommended for higher rate limits):

```bash
export GITHUB_TOKEN=your_token_here
python main.py your-org-name
```

Or pass it directly:

```bash
python main.py your-org-name --token your_token_here
```

### Include Completed Runs

Show completed runs from the last 8 hours (default):

```bash
python main.py your-org-name --include-completed-since-hours 8
```

Show completed runs from the last 24 hours:

```bash
python main.py your-org-name --include-completed-since-hours 24
```

### Fetch All Repositories

By default, the tool filters repositories based on recent activity to reduce API calls. This excludes dependabot-triggered jobs. To check all repositories:

```bash
python main.py your-org-name --fetch-all-repos
```

## Output

The tool displays a table with the following columns:

- **Repo**: Repository name
- **Started At**: When the workflow run started (formatted as "DD. Mon HH:MM")
- **Title**: Workflow run title (truncated if too long)
- **Status**: Current status (blue for active, grey for completed)
- **Conclusion**: Final result (green for success, red for failure, grey for cancelled)

## Authentication

You need a GitHub personal access token with appropriate permissions to access organization repositories and workflow runs. Ideally, create a fine-grained token. The token should have read-only access to `Actions`, `Contents` and `Metadata` of all repositories.

## Rate Limits

The tool makes parallel requests to improve performance but respects GitHub's API rate limits. With authentication, you get 5,000 requests per hour. Without authentication, you're limited to 60 requests per hour.

## Examples

```bash
# Monitor active runs only
python main.py acme-corp

# Include completed runs from last 12 hours
python main.py acme-corp --include-completed-since-hours 12

# Check all repositories (slower but comprehensive)
python main.py acme-corp --fetch-all-repos --include-completed-since-hours 6
```
