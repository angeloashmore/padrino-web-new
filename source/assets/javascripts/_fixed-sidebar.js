(function() {
  window.onscroll = setSidebarToFixedPosition;
})();

function setSidebarToFixedPosition() {
  var element = document.getElementById('sidebar');
  var scrollY = window.scrollY;
  var className = 'sidebar' + (scrollY >= 125 ? '--fixed' : '');
  element.className = className;
}
