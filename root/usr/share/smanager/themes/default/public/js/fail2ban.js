(function () {
  function initF2bTabs() {
    var tablist = document.querySelector('.fail2ban-panel .f2b-tabs');
    if (!tablist) return;
    if (tablist.dataset.tabsBound === '1') return;
    tablist.dataset.tabsBound = '1';

    var tabs   = Array.prototype.slice.call(tablist.querySelectorAll('.f2b-tab'));
    var panels = Array.prototype.slice.call(
      document.querySelectorAll('.fail2ban-panel .f2b-tabpanel')
    );

    function activate(mode) {
      tabs.forEach(function (tab) {
        var active = tab.dataset.mode === mode;
        tab.classList.toggle('is-active', active);
        tab.setAttribute('aria-selected', active ? 'true' : 'false');
      });
      panels.forEach(function (panel) {
        var show = panel.id === 'f2b-tabpanel-' + mode;
        panel.classList.toggle('is-hidden', !show);
      });
    }

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function (e) {
        e.preventDefault();
        activate(tab.dataset.mode);
      });
    });
  }

  document.addEventListener('DOMContentLoaded', initF2bTabs);
})();
