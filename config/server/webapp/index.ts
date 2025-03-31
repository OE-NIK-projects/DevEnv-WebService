const DEVMODE = process.env["DEVMODE"] !== "false";
const PORT = process.env["PORT"] || "8080";

const pricesData = await Bun.file("./public/db/services.json").json();

const server = Bun.serve({
	development: Boolean(DEVMODE),
	port: Number(PORT),
	hostname: "0.0.0.0",
	fetch(req) {
		const url = new URL(req.url);
		let filePath: string;

		switch (url.pathname) {
			case "/":
				filePath = "./public/index.html";
				break;
			case "/pricing":
				filePath = "./public/pricing.html";
				break;
			case "/services":
				filePath = "./public/services.html";
				break;
			case "/contact":
				filePath = "./public/contact.html";
				break;
			case "/api/status":
				return new Response("OK", { status: 200 });
			case "/api/services":
				filePath = "./public/db/services.json";
				break;
			case "/api/calculate": {
				const serviceId = url.searchParams.get("service");
				const hours = parseInt(url.searchParams.get("hours")) || 1;

				const service = pricesData.services.find((s) => s.id === serviceId);
				if (!service) {
					return Response.json({ error: "Service not found" }, { status: 404 });
				}

				const price = service.pricePerHour * hours;
				return Response.json(
					{
						price: price,
						currency: service.currency,
					},
					{ status: 200 }
				);
			}
			default:
				if (url.pathname.startsWith("/api/")) {
					return Response.json({ message: "Not found" }, { status: 404 });
				}
				filePath = `./public${url.pathname}`;
		}

		const file = Bun.file(filePath);
		if (file.size > 0) {
			const contentType = getContentType(filePath);
			return new Response(file, { headers: { "Content-Type": contentType } });
		}
		return new Response("Not Found", { status: 404 });
	},
});

function getContentType(filePath: string): string {
	if (filePath.endsWith(".html")) return "text/html";
	if (filePath.endsWith(".css")) return "text/css";
	if (filePath.endsWith(".js")) return "application/javascript";
	if (filePath.endsWith(".svg")) return "image/svg+xml";
	if (filePath.endsWith(".json")) return "application/json";
	return "application/octet-stream";
}

console.log(`Listening on http://0.0.0.0:${server.port}`);
