const DEVMODE = process.env["DEVMODE"] !== "false";
const PORT = process.env["PORT"] || "8080";

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
			case "/api/prices":
				filePath = "./public/prices.json";
				break;
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
	return "application/octet-stream";
}

console.log(`Listening on http://localhost:${server.port} ...`);
