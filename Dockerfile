# Use the official Node.js image for building the app
FROM node:22.4.0 AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json for dependency installation
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN npm run build

# Production-ready lightweight image
FROM node:22.4.0-slim AS runner

# Set the working directory
WORKDIR /app

# Install production dependencies only
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Copy the built application from the builder stage
# Copy built assets and necessary files
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
# Copy the check-env-variables file
COPY --from=builder /app/check-env-variables.js ./

# Set the correct port
ENV PORT=9001
EXPOSE 9001
CMD ["npm", "start"]
