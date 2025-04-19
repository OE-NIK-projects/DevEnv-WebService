// Function to set a cookie
function setCookie(name, value, days) {
    const expires = new Date();
    expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
    document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`;
}

// Function to get a cookie
function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(";").shift();
    return null;
}

// Theme toggle with cookie saving
function toggleTheme() {
    const body = document.body;
    if (body.classList.contains("dark-mode")) {
        body.classList.remove("dark-mode");
        body.classList.add("light-mode");
        setCookie("theme", "light", 365);
    } else {
        body.classList.remove("light-mode");
        body.classList.add("dark-mode");
        setCookie("theme", "dark", 365);
    }
}

// Load theme from cookie
function loadTheme() {
    const savedTheme = getCookie("theme");
    const body = document.body;
    if (savedTheme === "light") {
        body.classList.remove("dark-mode");
        body.classList.add("light-mode");
    } else {
        // Default to dark mode if cookie is "dark" or unset
        body.classList.remove("light-mode");
        body.classList.add("dark-mode");
    }
}

// Navigation for buttons with href
document.querySelectorAll(".nav-button, .mud-button[href]").forEach(button => {
    button.addEventListener("click", (e) => {
        e.preventDefault();
        window.location.href = button.getAttribute("href");
    });
});

// Highlight active page
function setActiveNav() {
    const currentPath = window.location.pathname;
    document.querySelectorAll(".nav-button").forEach(button => {
        if (button.getAttribute("href") === currentPath) {
            button.classList.add("active");
        } else {
            button.classList.remove("active");
        }
    });
}

// Run on page load
window.addEventListener("load", () => {
    loadTheme(); // Load theme first
    setActiveNav(); // Then set active nav
});

// Update on navigation (for browser back/forward)
window.addEventListener("popstate", setActiveNav);
