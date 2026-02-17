module.exports = async function taskCronHook(taskService) {
  // Example: find tasks due in next 24h and log
  const now = new Date();
  const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const dueTasks = await taskService.find({});
  const upcoming = dueTasks.filter(t => t.dueAt && new Date(t.dueAt) <= tomorrow && t.status !== 'done');
  if (upcoming.length) {
    console.log('Upcoming tasks due within 24h:');
    upcoming.forEach(t => console.log(`${t.id}: ${t.title} (due ${t.dueAt})`));
  }
};
