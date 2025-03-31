async function fetchServices() {
	try {
		const response = await fetch("/api/services");
		return await response.json();
	} catch (error) {
		document.getElementById("price-result").textContent =
			"Hiba történt az árlista lekérdezésekor.";
		console.error(error);
	}
}

function generateOptions(services) {
	const options = [];
	for (const service of services) {
		const option = document.createElement("option");
		option.value = service.id;
		option.textContent = `${service.name} (${service.pricePerHour} ${service.currency} / Óra)`;
		options.push(option);
	}
	return options;
}

async function loadServices() {
	const data = await fetchServices();
	const options = generateOptions(data.services);
	const services = document.getElementById("service-select");

	for (const option of options) {
		services.appendChild(option);
	}
}

async function getPrice() {
    const select = document.getElementById("service-select");
    const hoursInput = document.getElementById("hours-input");
    
    const selectedServiceId = select.value;
    const hours = parseInt(hoursInput.value) || 1;

    if (!selectedServiceId) {
        document.getElementById("price-result").textContent = 
            "Kérjük, válasszon szolgáltatást!";
        return;
    }
    if (hours < 1) {
        document.getElementById("price-result").textContent = 
            "Az órák száma minimum 1 kell legyen!";
        return;
    }

    try {
        const response = await fetch(`/api/calculate?service=${selectedServiceId}&hours=${hours}`);
        const data = await response.json();

        if (response.ok) {
            const formatter = new Intl.NumberFormat('hu-HU');
            const formattedPrice = formatter.format(data.price);
            document.getElementById("price-result").textContent = 
                `Ár: ${formattedPrice} ${data.currency}`;
        } else {
            document.getElementById("price-result").textContent = 
                "Hiba: " + (data.error || "Ismeretlen hiba");
        }
    } catch (error) {
        document.getElementById("price-result").textContent = 
            "Hiba a számítás során.";
        console.error(error);
    }
}

loadServices();
