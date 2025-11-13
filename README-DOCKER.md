# 🐳 Guía de Dockerización y Despliegue

## 📋 Explicación de los Archivos

### 1. Dockerfile
El **Dockerfile** define cómo se construye la imagen Docker. Usa un enfoque multi-stage:

- **Etapa 1 (Build)**: Compila el proyecto con Maven
  - Usa `maven:3.9-amazoncorretto-17` con todas las herramientas
  - Copia dependencias y código fuente
  - Genera el archivo JAR

- **Etapa 2 (Runtime)**: Ejecuta la aplicación
  - Usa `amazoncorretto:17-alpine` (imagen ligera, ~150MB)
  - Solo contiene el JRE y el JAR
  - Expone el puerto 3005

### 2. .dockerignore
Excluye archivos innecesarios del contexto de Docker (como .gitignore):
- Archivos compilados (target/)
- Configuraciones de IDE
- Archivos temporales

### 3. docker-compose.yml
Orquesta múltiples servicios y simplifica el deployment:
- Define la configuración de la app
- Incluye ejemplo de base de datos MySQL (comentado)
- Configura redes y volúmenes

---

## 🚀 Comandos para Dockerizar y Desplegar

### **Paso 1: Construir la Imagen Docker**
```bash
# Opción A: Con Docker directamente
docker build -t adso-app:latest .

# Opción B: Con Docker Compose
docker-compose build
```

### **Paso 2: Ejecutar el Contenedor Localmente**
```bash
# Opción A: Con Docker directamente
docker run -d -p 3005:3005 --name adso-app adso-app:latest

# Opción B: Con Docker Compose (recomendado)
docker-compose up -d
```

### **Paso 3: Verificar que Funciona**
```bash
# Ver logs
docker logs adso-app

# O con Docker Compose
docker-compose logs -f app

# Probar la aplicación
curl http://localhost:3005
```

### **Comandos Útiles**
```bash
# Ver contenedores en ejecución
docker ps

# Detener el contenedor
docker stop adso-app
# O con Docker Compose
docker-compose down

# Reiniciar
docker restart adso-app
# O con Docker Compose
docker-compose restart

# Ver logs en tiempo real
docker logs -f adso-app

# Entrar al contenedor (para debugging)
docker exec -it adso-app /bin/sh

# Eliminar todo y reconstruir
docker-compose down -v
docker-compose up -d --build
```

---

## ☁️ Despliegue en Producción

### **Opción 1: Docker Hub + Servidor Cloud**

#### A. Subir imagen a Docker Hub
```bash
# 1. Login en Docker Hub
docker login

# 2. Etiquetar la imagen
docker tag adso-app:latest tu-usuario/adso-app:latest

# 3. Subir la imagen
docker push tu-usuario/adso-app:latest
```

#### B. Desplegar en un servidor (AWS, DigitalOcean, etc.)
```bash
# En el servidor:
ssh usuario@tu-servidor

# Descargar y ejecutar
docker pull tu-usuario/adso-app:latest
docker run -d -p 80:3005 --name adso-app tu-usuario/adso-app:latest
```

---

### **Opción 2: Heroku**
```bash
# 1. Instalar Heroku CLI y login
heroku login

# 2. Crear app
heroku create tu-app-name

# 3. Login en Heroku Container Registry
heroku container:login

# 4. Build y push
heroku container:push web -a tu-app-name

# 5. Release
heroku container:release web -a tu-app-name

# 6. Abrir la app
heroku open -a tu-app-name
```

---

### **Opción 3: AWS Elastic Container Service (ECS)**
1. Subir imagen a **AWS ECR** (Elastic Container Registry)
2. Crear un **Task Definition** en ECS
3. Crear un **Service** que ejecute tu contenedor
4. Configurar **Load Balancer** para acceso público

---

### **Opción 4: Google Cloud Run**
```bash
# 1. Instalar gcloud CLI y autenticarse
gcloud auth login

# 2. Configurar proyecto
gcloud config set project tu-proyecto

# 3. Build y deploy (Cloud Run build automáticamente)
gcloud run deploy adso-app \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

---

### **Opción 5: Azure Container Instances**
```bash
# 1. Login en Azure
az login

# 2. Crear grupo de recursos
az group create --name adso-rg --location eastus

# 3. Crear registro de contenedores
az acr create --resource-group adso-rg --name adsoacr --sku Basic

# 4. Build y push
az acr build --registry adsoacr --image adso-app:latest .

# 5. Desplegar
az container create \
  --resource-group adso-rg \
  --name adso-app \
  --image adsoacr.azurecr.io/adso-app:latest \
  --dns-name-label adso-app \
  --ports 3005
```

---

## 🔧 Configuración de Producción

### Variables de Entorno
Crea un archivo `.env` para producción:
```env
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=3005
JWT_SECRET=tu-secret-seguro-y-largo
DATABASE_URL=jdbc:mysql://host:3306/db
DATABASE_USERNAME=user
DATABASE_PASSWORD=password
```

Usa con Docker:
```bash
docker run --env-file .env -p 3005:3005 adso-app:latest
```

---

## 📊 Monitoreo y Logs

### Ver logs en tiempo real
```bash
docker logs -f adso-app
```

### Limitar tamaño de logs
```bash
docker run --log-opt max-size=10m --log-opt max-file=3 adso-app:latest
```

---

## 🛡️ Seguridad

1. **No incluir secretos en la imagen**: Usa variables de entorno
2. **Escanear vulnerabilidades**:
   ```bash
   docker scan adso-app:latest
   ```
3. **Usar imágenes oficiales y actualizadas**
4. **Ejecutar como usuario no-root** (opcional, avanzado)

---

## 🎯 Resumen de Pasos

1. ✅ **Crear archivos**: Dockerfile, .dockerignore, docker-compose.yml
2. ✅ **Build**: `docker-compose build`
3. ✅ **Ejecutar localmente**: `docker-compose up -d`
4. ✅ **Probar**: `curl http://localhost:3005`
5. ✅ **Desplegar**: Elegir plataforma y seguir sus pasos

---

## 📞 Soporte

Si tienes problemas:
- Verifica logs: `docker logs adso-app`
- Revisa puertos: `netstat -an | findstr 3005`
- Rebuilds: `docker-compose up -d --build`
