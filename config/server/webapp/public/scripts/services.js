async function fetchServices() {
	try {
		const response = await fetch("/api/services");
		return await response.json();
	} catch (error) {
		document.getElementById("services").textContent =
			"Hiba a szolgáltatások betöltésekor.";
		console.error(error);
	}
}

function generateCard(name, desc) {
	const mainDiv = document.createElement("div");
	const cardDiv = document.createElement("div");
	const contentDiv = document.createElement("div");
	const title = document.createElement("h5");
	const paragraph = document.createElement("p");

	mainDiv.className = "mud-item xs-12 md-4";
	cardDiv.className = "mud-card h-100";
	contentDiv.className = "mud-card-content";
	title.className = "mud-text-h5";
	paragraph.className = "mud-text";

	title.textContent = name;
	paragraph.textContent = desc;

	contentDiv.appendChild(title);
	contentDiv.appendChild(paragraph);
	cardDiv.appendChild(contentDiv);
	mainDiv.appendChild(cardDiv);

	return mainDiv;
}

async function loadServices() {
	const data = await fetchServices();
	const grid = document.getElementById("services");

	for (const service of data.services) {
		const card = generateCard(service.name, service.description);
		grid.appendChild(card);
	}
}

loadServices();
