function applySavedAccessibilitySettings() {
    const savedFontSize = localStorage.getItem('fontSize');
    if (savedFontSize) {
        document.documentElement.style.fontSize = savedFontSize;
    }
}

function setupFontSizeControls() {
    const increaseFontBtn = document.getElementById('font-increase-btn');
    const decreaseFontBtn = document.getElementById('font-decrease-btn');
    const resetFontBtn = document.getElementById('font-reset-btn');

    const changeFontSize = (amount) => {
        const html = document.documentElement;
        let currentSize = parseFloat(window.getComputedStyle(html).fontSize) || 16;
        let newSize = currentSize + amount;
        
        if (newSize < 12) newSize = 12; 
        if (newSize > 24) newSize = 24;

        html.style.fontSize = `${newSize}px`;

        localStorage.setItem('fontSize', `${newSize}px`);
    };

    if (increaseFontBtn) increaseFontBtn.addEventListener('click', () => changeFontSize(1));
    if (decreaseFontBtn) decreaseFontBtn.addEventListener('click', () => changeFontSize(-1));
    if (resetFontBtn) resetFontBtn.addEventListener('click', () => {
        document.documentElement.style.fontSize = ''; 
        localStorage.removeItem('fontSize');
    });
}

document.addEventListener('DOMContentLoaded', () => {
    applySavedAccessibilitySettings();
    setupFontSizeControls();

    const menuToggleBtn = document.getElementById('menuDropdownToggle');
    const menuDropdown = document.getElementById('menuDropdown');

    const accessibilityToggleBtn = document.getElementById('header-accessibility-toggle-btn');
    const accessibilityMenu = document.getElementById('header-accessibility-menu');

    if (menuToggleBtn && menuDropdown) {
        menuToggleBtn.addEventListener('click', (event) => {
            event.stopPropagation();
            if (accessibilityMenu && accessibilityMenu.classList.contains('show')) {
                accessibilityMenu.classList.remove('show');
                if (accessibilityToggleBtn) accessibilityToggleBtn.setAttribute('aria-expanded', 'false');
            }
            menuDropdown.classList.toggle('show');
            const isExpanded = menuDropdown.classList.contains('show');
            menuToggleBtn.setAttribute('aria-expanded', isExpanded);
        });
    }

    if (accessibilityToggleBtn && accessibilityMenu) {
        accessibilityToggleBtn.addEventListener('click', (event) => {
            event.stopPropagation();
            if (menuDropdown && menuDropdown.classList.contains('show')) {
                menuDropdown.classList.remove('show');
                if (menuToggleBtn) menuToggleBtn.setAttribute('aria-expanded', 'false');
            }
            accessibilityMenu.classList.toggle('show');
            const isExpanded = accessibilityMenu.classList.contains('show');
            accessibilityToggleBtn.setAttribute('aria-expanded', isExpanded);
        });
    }

    window.addEventListener('click', (event) => {
        if (menuDropdown && menuDropdown.classList.contains('show') && !menuToggleBtn.contains(event.target)) {
            menuDropdown.classList.remove('show');
            menuToggleBtn.setAttribute('aria-expanded', 'false');
        }

        if (accessibilityMenu && accessibilityMenu.classList.contains('show') && !accessibilityToggleBtn.contains(event.target)) {
            if (!accessibilityMenu.contains(event.target)) {
                accessibilityMenu.classList.remove('show');
                accessibilityToggleBtn.setAttribute('aria-expanded', 'false');
            }
        }
    });
});