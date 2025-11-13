# ETAPA 1: Construcción (Build Stage)
# Usamos una imagen de Maven con JDK 17 para compilar el proyecto
FROM maven:3.9-amazoncorretto-17 AS build

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos de configuración de Maven primero (para cache de dependencias)
COPY pom.xml .

# Descargamos las dependencias (se cachean si pom.xml no cambia)
RUN mvn dependency:go-offline -B

# Copiamos el código fuente
COPY src ./src

# Compilamos el proyecto y creamos el JAR
# -DskipTests: omite los tests para acelerar el build
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución (Runtime Stage)
# Usamos una imagen más ligera solo con JRE para ejecutar la aplicación
FROM amazoncorretto:17-alpine

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos el JAR compilado desde la etapa de build
COPY --from=build /app/target/adso-0.0.1-SNAPSHOT.jar app.jar

# Exponemos el puerto donde correrá la aplicación
EXPOSE 3005

# Variables de entorno (pueden sobrescribirse al ejecutar el contenedor)
ENV SPRING_PROFILES_ACTIVE=prod

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
