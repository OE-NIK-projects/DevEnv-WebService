FROM oven/bun:latest AS builder
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install
COPY . .
RUN bun run build

FROM oven/bun:latest AS runner
WORKDIR /app
COPY --from=builder /app/build /app
EXPOSE 80
CMD [ "bun", "run", "index.js"]
