# OC Task Manager

**Version:** 1.0.0  
**License:** MIT  
**Repository:** https://github.com/pjain/OC-Task-Manager

A lightweight, JSON-first task management system designed for Clawd agents and human users. Tasks are stored as human-readable JSON files (git-native), with an optional web dashboard for visual management.

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone git@github.com:pjain/OC-Task-Manager.git
cd OC-Task-Manager

# Run the installer
./install.sh

# Or manually:
# Link CLI to your PATH
ln -s $(pwd)/bin/task /usr/local/bin/clawd-task

# Initialize data directory
clawd-task init

# Create your first task
clawd-task create "My first task" --due "tomorrow 9am" --priority high

# List tasks
clawd-task list
```

---

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [CLI Usage](#cli-usage)
- [JavaScript API](#javascript-api)
- [Web Dashboard](#web-dashboard)
- [Dependencies](#dependencies)
- [Team & Roadmap](#team--roadmap)
- [Changelog](#changelog)

---

## ✨ Features

| Feature | Status | Description |
|---------|--------|-------------|
| **JSON-First Storage** | ✅ Ready | Human-readable, git-native JSON files |
| **CLI Interface** | ✅ Ready | Command-line tool for task CRUD |
| **Web Dashboard** | ✅ Ready | Visual HTML/JS dashboard |
| **JavaScript API** | ✅ Ready | Programmatic access via Node.js |
| **Task Lifecycle** | ✅ Ready | `todo` → `in-progress` → `done` |
| **Status Tracking** | ✅ Ready | Full status: todo, in-progress, blocked, cancelled, done |
| **Priority Levels** | ✅ Ready | low, medium, normal, high, critical |
| **Due Dates** | ✅ Ready | ISO 8601 datetime support |
| **Task Ownership** | ✅ Ready | Assign tasks to agents or users |
| **Tags & Projects** | ✅ Ready | Organize tasks with metadata |
| **Soft Delete** | ✅ Ready | Archive tasks without losing history |
| **Audit Trail** | 🔄 Planned | Full action history (JSONL log) |
| **SQLite Index** | 🔄 Planned | Optional indexing for complex queries |
| **Subtasks** | 🔄 Planned | Hierarchical task support |
| **Cron Hooks** | 🔄 Planned | Automated task reminders |

---

## Architecture

```
OC-Task-Manager/
├── README.md              # This file
├── LICENSE                # MIT License
├── SKILL.md               # Skill documentation
├── install.sh             # Installation script
├── bin/
│   ├── task               # CLI entry point
│   └── migrate-from-markdown.js  # Migration tool
├── lib/
│   ├── task-service.js    # Core API (JSON storage)
│   └── sqlite-index.js    # Optional SQLite indexer (future)
├── ui/
│   └── dashboard.html     # Web dashboard
├── hooks/
│   └── cron.js            # Cron integration example
└── data/                  # Data directory (created on init)
    ├── tasks.json         # Primary task storage
    └── history.jsonl      # Audit log (append-only)
```

---

## Installation

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** or **bun** (for package management)
- **Git** (optional, for cloning)

### Option 1: Automated Installation (Recommended)

```bash
git clone git@github.com:pjain/OC-Task-Manager.git
cd OC-Task-Manager
chmod +x install.sh
./install.sh
```

The install script will:
1. Check for Node.js >= 18
2. Create the data directory
3. Link the CLI to `/usr/local/bin/clawd-task` (or `~/.local/bin/`)
4. Create default configuration at `~/.config/clawd/task-manager.json`
5. Initialize the task database

### Option 2: Manual Installation

```bash
# 1. Clone repository
git clone git@github.com:pjain/OC-Task-Manager.git
cd OC-Task-Manager

# 2. Link CLI to PATH
# System-wide:
sudo ln -s $(pwd)/bin/task /usr/local/bin/clawd-task
# Or user-local:
mkdir -p ~/.local/bin
ln -s $(pwd)/bin/task ~/.local/bin/clawd-task
export PATH="$HOME/.local/bin:$PATH"

# 3. Create data directory
clawd-task init

# 4. Verify installation
clawd-task --help
```

### Option 3: Installation via Clawhub (Future)

When published to Clawhub:

```bash
clawhub install task-manager
```

---

## Configuration

Create `~/.config/clawd/task-manager.json`:

```json
{
  "dataDir": "/Users/clawd/clawd/skills/task-manager/data",
  "enableSQLite": false,
  "autoSnapshot": true,
  "snapshotInterval": "1h",
  "defaultOwner": "clawd",
  "defaultProject": "main"
}
```

| Option | Default | Description |
|--------|---------|-------------|
| `dataDir` | `./data` | Location of task database |
| `enableSQLite` | `false` | Enable SQLite indexing (future) |
| `autoSnapshot` | `true` | Auto-create backups |
| `snapshotInterval` | `1h` | Snapshot frequency |
| `defaultOwner` | `null` | Default task owner |
| `defaultProject` | `null` | Default project name |

---

## CLI Usage

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `init` | Initialize data directory | `clawd-task init` |
| `create <title>` | Create a new task | `clawd-task create "Fix bug" --due "tomorrow"` |
| `list` | List all tasks | `clawd-task list --status todo` |
| `show <id>` | Show task details | `clawd-task show TASK-001` |
| `update <id>` | Update a task | `clawd-task update TASK-001 --status done` |
| `complete <id>` | Mark task complete | `clawd-task complete TASK-001` |
| `delete <id>` | Soft delete task | `clawd-task delete TASK-001` |
| `export` | Export tasks | `clawd-task export --format json > tasks.json` |

### Create Task Options

```bash
clawd-task create "Build dashboard" \
  --desc "Create HTML/JS dashboard for task visualization" \
  --due "2026-02-17T09:00:00" \
  --owner max \
  --priority high \
  --tags frontend,ui,urgent
```

**Priority Levels:**
- `low` (-2)
- `medium` (-1)
- `normal` (0) — default
- `high` (1)
- `critical` (2)

### List Tasks

```bash
# List all active tasks
clawd-task list

# Filter by status
clawd-task list --status todo

# Filter by owner
clawd-task list --owner max

# Combined filters
clawd-task list --status todo --owner max
```

### Update Tasks

```bash
# Change status
clawd-task update TASK-001 --status in-progress

# Change due date
clawd-task update TASK-002 --due "next week"

# Change owner
clawd-task update TASK-003 --owner sage

# Multiple updates
clawd-task update TASK-001 --status done --priority low
```

---

## JavaScript API

### Basic Usage

```javascript
const { TaskService } = require('./lib/task-service');

const tasks = new TaskService('/path/to/data');

// Create task
const task = await tasks.create({
  title: 'Build dashboard',
  description: 'Create HTML/JS dashboard',
  due: '2026-02-17T09:00:00Z',
  owner: 'max',
  priority: 'high',
  tags: ['frontend', 'ui'],  
  project: 'task-manager'
});

// Query tasks
const myTasks = await tasks.find({
  status: 'todo',
  owner: 'max'
});

// Get task by ID
const found = await tasks.get(task.id);

// Update task
await tasks.update(task.id, { status: 'in-progress' });

// Complete task
await tasks.complete(task.id);

// Delete (soft delete)
await tasks.delete(task.id);
```

### Task Lifecycle

```
todo → in-progress → done
  ↓       ↓
blocked ←───┘
  ↓
cancelled
```

---

## Web Dashboard

The dashboard provides a visual interface for managing tasks.

### Setup

```bash
# 1. Export tasks to JSON
cd /path/to/task-manager
./bin/task export --format json > ~/Sites/tasks/data.json

# 2. Copy dashboard
cp ui/dashboard.html ~/Sites/tasks/index.html

# 3. Open in browser
open ~/Sites/tasks/index.html
```

### Features

- Table view of all tasks
- Sortable columns (click headers)
- Real-time updates (refresh to reload)
- Status color coding

### Future Dashboard Features

- [ ] Drag-and-drop reordering
- [ ] Status transitions