function toggleTheme() {
    const body = document.body;
    if (body.classList.contains("dark-mode")) {
        body.classList.remove("dark-mode");
        body.classList.add("light-mode");
    } else {
        body.classList.remove("light-mode");
        body.classList.add("dark-mode");
    }
}

document.querySelectorAll(".nav-button, .mud-button[href]").forEach(button => {
    button.addEventListener("click", (e) => {
        e.preventDefault();
        window.location.href = button.getAttribute("href");
    });
});

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

window.addEventListener("load", setActiveNav);
window.addEventListener("popstate", setActiveNav);