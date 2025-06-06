const menuDropdownToggle = document.getElementById('menuDropdownToggle');
const menuDropdown = document.getElementById('menuDropdown');

if (menuDropdownToggle && menuDropdown) {
    menuDropdownToggle.addEventListener('click', function(event) {
        event.stopPropagation();
        menuDropdown.classList.toggle('show');
        this.classList.toggle('active');
    });

    window.addEventListener('click', function(event) {
        if (menuDropdown.classList.contains('show') && 
            !menuDropdownToggle.contains(event.target) && 
            !menuDropdown.contains(event.target)) {
            
            menuDropdown.classList.remove('show');
            menuDropdownToggle.classList.remove('active');
        }
    });
}