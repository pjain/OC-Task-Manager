#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { TaskService } = require('../lib/task-service');

if (process.argv.length < 3) {
  console.error('Usage: migrate-from-markdown.js <source-markdown>');
  process.exit(1);
}

const sourcePath = path.resolve(process.argv[2]);
const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });
const service = new TaskService(dataDir);

const markdown = fs.readFileSync(sourcePath, 'utf8');
const lines = markdown.split('\n');
let currentTask = null;
for (const line of lines) {
  // Very naive detection: lines starting with "- [ ]" or "- [x]" as tasks
  const match = line.match(/^\s*- \[( |x)\] (.+)$/);
  if (match) {
    const done = match[1] === 'x';
    const title = match[2].trim();
    // create task
    service.create({
      title,
      status: done ? 'done' : 'todo'
    }).catch(console.error);
  }
}

console.log('Migration completed.');
