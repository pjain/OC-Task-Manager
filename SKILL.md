# Task Manager Skill

**Version:** 1.0.0  
**Author:** Clawd Architecture Team  
**Date:** February 16, 2026

## Overview

A lightweight, JSON-first task management system designed for Clawd agents. Tasks are stored as human-readable JSON files (git-native), with optional SQLite indexing for complex queries.

## Architecture

```
skills/task-manager/
├── SKILL.md              # This file
├── bin/task              # CLI entry point
├── lib/
│   ├── task-service.js   # Core API (JSON storage)
│   └── sqlite-index.js   # Optional SQLite indexer
├── ui/
│   └── dashboard.html    # Web dashboard
└── data/
    ├── tasks.json        # Primary task storage
    ├── history.jsonl     # Audit log (append-only)
    └── snapshots/        # Auto-snapshots
```

## Installation

```bash
# Link CLI to PATH
ln -s /Users/clawd/clawd/skills/task-manager/bin/task /usr/local/bin/clawd-task

# Initialize data directory
clawd-task init
```

## Configuration

Create `~/.config/clawd/task-manager.json`:

```json
{
  "dataDir": "/Users/clawd/clawd/skills/task-manager/data",
  "enableSQLite": false,
  "autoSnapshot": true,
  "snapshotInterval": "1h"
}
```

## CLI Usage

```bash
# Create a task
clawd-task create "Fix browser automation" --due "tomorrow 9am" --agent mini --priority high

# List tasks
clawd-task list --status todo --agent max

# Update task
clawd-task update TASK-001 --status in-progress

# Complete task
clawd-task complete TASK-001

# Show task details
clawd-task show TASK-001

# Delete task (soft delete)
clawd-task delete TASK-001

# Export for dashboard
clawd-task export --format json > ~/Sites/tasks/data.json
```

## JavaScript API

```javascript
const { TaskService } = require('./skills/task-manager/lib/task-service.js');

const tasks = new TaskService('/path/to/data');

// Create task
const task = await tasks.create({
  title: 'Build dashboard',
  description: 'Create HTML/JS dashboard',
  due: '2026-02-17T09:00:00Z',
  owner: 'max',
  priority: 'high',
  tags: ['frontend', 'ui']
});

// Query tasks
const myTasks = await tasks.find({
  status: ['todo', 'in-progress'],
  owner: 'max',
  sort: 'due'
});

// Update task
await tasks.update(task.id, { status: 'in-progress' });

// Complete task
await tasks.complete(task.id, { completedAt: new Date() });
```

## Storage Format

### Primary: tasks.json

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-02-16T20:58:00Z",
  "tasks": [
    {
      "id": "TASK-001",
      "title": "Build dashboard",
      "description": "Create HTML/JS dashboard",
      "status": "in-progress",
      "priority": 2,
      "createdAt": "2026-02-16T15:00:00Z",
      "updatedAt": "2026-02-16T20:58:00Z",
      "dueAt": "2026-02-17T09:00:00Z",
      "owner": "max",
      "tags": ["frontend", "ui"],
      "project": "task-manager"
    }
  ]
}
```

### Audit: history.jsonl (append-only)

```jsonl
{"timestamp":"2026-02-16T15:00:00Z","action":"created","taskId":"TASK-001","actor":"max"}
{"timestamp":"2026-02-16T20:58:00Z","action":"updated","taskId":"TASK-001","field":"status","oldValue":"todo","newValue":"in-progress","actor":"max"}
```

## Status Lifecycle

```
todo → in-progress → done
  ↓      ↓
blocked   ↓
  ↓      ↓
cancelled
```

Priorities: `-2:low, -1:medium, 0:normal, 1:high, 2:critical`

## Cron Integration

```javascript
// Add to heartbeat or cron job
const { TaskService } = require('./skills/task-manager/lib/task-service.js');
const tasks = new TaskService();

// Check for due tasks
const dueTasks = await tasks.find({
  dueBefore: new Date(Date.now() + 24 * 60 * 60 * 1000),
  status: ['todo', 'in-progress', 'blocked']
});

// Notify about upcoming deadlines
for (const task of dueTasks) {
  console.log(`Task ${task.id} due: ${task.title}`);
}
```

## Web Dashboard

Open `ui/dashboard.html` in a browser, or serve from `~/Sites/tasks/`:

```bash
# Export current tasks
cd skills/task-manager && ./bin/task export --format json > ~/Sites/tasks/data.json

# Open dashboard
open ~/Sites/tasks/index.html
```

## Migration from Markdown

```bash
# Run migration script
node skills/task-manager/bin/migrate-from-markdown.js \
  --source /path/to/AGENT-COORDINATION.md \
  --output skills/task-manager/data/tasks.json
```

## Team Roles

- **@Max:** Storage layer, API, CLI
- **@Mad:** Backup strategy, migration tooling
- **@Mini:** Dashboard UI, rapid prototyping

## Changelog

### v1.0.0 (2026-02-16)
- JSON-first storage architecture
- Task CRUD operations
- CLI interface
- Web dashboard
- Migration script from markdown
