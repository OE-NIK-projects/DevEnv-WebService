// Theme toggle (simulating MudBlazor's dark/light mode)
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

// Navigation (for buttons with href)
document.querySelectorAll(".mud-button[href]").forEach(button => {
    button.addEventListener("click", (e) => {
        e.preventDefault();
        window.location.href = button.getAttribute("href");
    });
});