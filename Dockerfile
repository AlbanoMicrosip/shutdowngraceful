FROM 203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/oracle-jdk:1.8_202 as build-stage
LABEL maintainer "Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>"
# Create workdir
RUN mkdir -p /home/microsip/microservice-build
WORKDIR /home/microsip/microservice-build
# Copying all gradle files necessary to install gradle with gradlew
COPY gradle gradle
COPY \
  ./gradle \
  build.gradle \
  gradle.properties \
  gradlew \
  ./

# Install the gradle version used in the repository through gradlew
RUN ./gradlew
# Run gradle assemble to install dependencies before adding the whole repository
#RUN ./gradlew assemble
# Copy Sources
ADD . ./
# Build & eclude tests
RUN ./gradlew clean build -x test

FROM 203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/oracle-jdk:1.8_202
LABEL maintainer "Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>"
#ARG LOGGLY_SUBDOMAIN
#ARG LOGGLY_USERNAME
#ARG LOGGLY_PASSWORD
RUN set -x \
    && apt-get update \
    && apt-get install -y -q --no-install-recommends \
        sudo \
#    && rm -rf /var/run/rsyslogd.pid \
#    && curl -O https://www.loggly.com/install/configure-linux.sh \
#    && chmod a+x configure-linux.sh \
#    && sed -i -- 's/service $RSYSLOG_SERVICE start/#service $RSYSLOG_SERVICE start/g' configure-linux.sh \
#    && ./configure-linux.sh -a $LOGGLY_SUBDOMAIN -u $LOGGLY_USERNAME -p $LOGGLY_PASSWORD -s \
#    && rm configure-linux.sh \
    && export SUDO_FORCE_REMOVE=yes \
    && apt-get purge -y --auto-remove sudo \
    && apt-get clean
ARG PORT
ENV PORT ${PORT:-8080}
VOLUME /tmp
EXPOSE $PORT
# ADD src/main/docker/docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
COPY --from=build-stage /home/microsip/microservice-build/build/libs/*.jar /app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
# RUN sh -c 'touch /app.jar'

# CMD ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar"]