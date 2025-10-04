// /frontend\static\js\notifications.js
document.addEventListener('DOMContentLoaded', () => {
  const list = document.getElementById('notificationsList');
  const btn = document.getElementById('btnAddMock');
  btn?.addEventListener('click', () => {
    const node = document.createElement('div');
    node.className = 'notification';
    node.textContent = 'Recordatorio demo: revisa tu presión arterial mañana 8:00 AM';
    list.prepend(node);
  });
});
