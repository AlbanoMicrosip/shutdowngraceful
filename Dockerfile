FROM 203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/oracle-jdk:1.8_202
# Variables para facilitar el cambio de la configuración del contenedor
ARG JAR_FILE=build/libs/*.jar
ENV APP_HOME=/usr/app

# Crear directorio de la aplicación
WORKDIR $APP_HOME

# Copiamos el JAR del proyecto al contenedor
COPY ${JAR_FILE} app.jar

# El comando para ejecutar nuestra aplicación Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]