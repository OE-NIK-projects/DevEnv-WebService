import index from "./public/index.html";
import pricing from "./public/pricing.html";
import services from "./public/services.html";
import contact from "./public/contact.html";

const DEVMODE = process.env["DEVMODE"] || false;
const PORT = process.env["PORT"] || "8080";

const server = Bun.serve({
	development: Boolean(DEVMODE),
	port: Number(PORT),
	hostname: "0.0.0.0",
	routes: {
		// HTML
		"/": index,
		"/pricing": pricing,
		"/services": services,
		"/contact": contact,

		// API
		"/api/status": new Response("OK"),
		"/api/*": Response.json({ message: "Not found" }, { status: 404 }),
	},
});

console.log(`Listening on http://localhost:${server.port} ...`);
