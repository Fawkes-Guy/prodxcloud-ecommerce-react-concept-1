# ---- Etapa 1: Build ----
# Usamos una imagen LTS (Long-Term Support) de Node más reciente
FROM node:22-alpine AS build

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos solo los archivos de dependencias para aprovechar la caché de Docker
COPY package.json package-lock.json ./

# Instalamos las dependencias
RUN npm install

# Copiamos el resto del código fuente del proyecto
COPY . .

# Ejecutamos el comando de build de Vite, que genera la carpeta 'dist'
RUN npm run build

# ---- Etapa 2: Serve ----
# Usamos una imagen de Nginx reciente y ligera
FROM nginx:1.27.0-alpine

# Copiamos la configuración personalizada de Nginx (la guía debería dartela después)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Eliminamos los archivos HTML por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiamos los archivos compilados desde la etapa 'build' a la carpeta de Nginx
# ¡IMPORTANTE! Usamos 'dist' en lugar de 'build'
COPY --from=build /app/dist /usr/share/nginx/html

# Exponemos el puerto 80, que es el que usa Nginx por defecto
EXPOSE 80

# Comando para iniciar Nginx cuando el contenedor se ejecute
CMD ["nginx", "-g", "daemon off;"]