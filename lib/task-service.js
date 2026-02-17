const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');

/** Simple JSON file based task service */
class TaskService {
  constructor(baseDir) {
    this.baseDir = baseDir;
    this.filePath = path.join(this.baseDir, 'tasks.json');
    if (!fs.existsSync(this.filePath)) {
      this._write({ version: '1.0.0', lastUpdated: new Date().toISOString(), tasks: [] });
    }
    this._load();
  }

  _load() {
    const raw = fs.readFileSync(this.filePath, 'utf8');
    this.state = JSON.parse(raw);
  }

  _write(state) {
    state.lastUpdated = new Date().toISOString();
    fs.writeFileSync(this.filePath, JSON.stringify(state, null, 2), 'utf8');
    this.state = state;
  }

  _save() { this._write(this.state); }

  async create({ title, description = '', due = null, priority = 'normal', owner = null, project = null, parentId = null, tags = [], sourceContext = '' }) {
    const id = 'TASK-' + randomUUID();
    const now = new Date().toISOString();
    const task = {
      id,
      title,
      description,
      status: 'todo',
      priority: this._priorityNum(priority),
      createdAt: now,
      updatedAt: now,
      dueAt: due ? new Date(due).toISOString() : null,
      owner,
      project,
      parentId,
      tags,
      sourceContext,
      isPinned: false,
      isArchived: false
    };
    this.state.tasks.push(task);
    this._save();
    return task;
  }

  _priorityNum(level) {
    const map = { low: -2, medium: -1, normal: 0, high: 1, critical: 2 };
    return map[level] !== undefined ? map[level] : 0;
  }

  async find(filter = {}) {
    return this.state.tasks.filter(t => {
      if (filter.status && t.status !== filter.status) return false;
      if (filter.owner && t.owner !== filter.owner) return false;
      if (filter.project && t.project !== filter.project) return false;
      return true;
    });
  }

  async get(id) {
    return this.state.tasks.find(t => t.id === id);
  }

  async update(id, updates = {}) {
    const task = await this.get(id);
    if (!task) throw new Error('Task not found');
    Object.assign(task, updates);
    task.updatedAt = new Date().toISOString();
    if (updates.due) task.dueAt = new Date(updates.due).toISOString();
    this._save();
    return task;
  }

  async complete(id) {
    return this.update(id, { status: 'done', completedAt: new Date().toISOString() });
  }

  async delete(id) {
    const idx = this.state.tasks.findIndex(t => t.id === id);
    if (idx === -1) throw new Error('Task not found');
    // soft delete – mark archived
    this.state.tasks[idx].isArchived = true;
    this.state.tasks[idx].updatedAt = new Date().toISOString();
    this._save();
  }

  async export(format = 'json') {
    if (format === 'jsonl') {
      return this.state.tasks.map(t => JSON.stringify(t)).join('\n');
    }
    return this.state;
  }
}

module.exports = { TaskService };
