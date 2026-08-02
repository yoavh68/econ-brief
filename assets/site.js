/* דוח מצב כלכלי יומי — לוגיקת אתר: מצב כהה/בהיר + שנה בפוטר */
(function () {
  var KEY = 'econ-theme';
  var root = document.documentElement;

  function saved() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }
  function store(v) {
    try { localStorage.setItem(KEY, v); } catch (e) {}
  }
  function current() {
    var t = root.getAttribute('data-theme');
    if (t) return t;
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark' : 'light';
  }
  function paint(btn) {
    if (btn) btn.textContent = current() === 'dark' ? '☀️' : '🌙';
  }

  var pref = saved();
  if (pref) root.setAttribute('data-theme', pref);

  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.getElementById('themeBtn');
    paint(btn);
    if (btn) {
      btn.addEventListener('click', function () {
        var next = current() === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        store(next);
        paint(btn);
      });
    }
    var y = document.getElementById('year');
    if (y) y.textContent = new Date().getFullYear();
  });
})();
