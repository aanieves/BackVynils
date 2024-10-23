# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copiar solo los archivos necesarios para instalar dependencias
COPY package.json package-lock.json ./

# Instalar dependencias de producción
RUN npm ci --only=production --quiet

# Copiar el resto de la aplicación
COPY . .

# Compilar la aplicación (si aplica)
RUN npm run build

# Stage 2: Production
FROM node:18-alpine

WORKDIR /usr/src/app

# Copiar solo los archivos de producción
COPY package.json package-lock.json ./

# Instalar dependencias de producción
RUN npm ci --only=production --quiet

# Copiar los archivos compilados desde el stage de build
COPY --from=builder /usr/src/app/dist ./dist

# Establecer variables de entorno
ENV NODE_ENV=production

# Exponer el puerto necesario
EXPOSE 3000

# Limitar el uso de memoria de Node.js a 256MB
CMD ["node", "--max-old-space-size=256", "dist/main.js"]
