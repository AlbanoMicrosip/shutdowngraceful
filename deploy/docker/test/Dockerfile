FROM 203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/oracle-jdk:1.8_202
LABEL maintainer "Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>"
RUN echo "Home is $HOME" && echo `whoami`
RUN mkdir -p $HOME/.embedmongo/linux $HOME/.embedmongo/extracted
# Create workdir
RUN mkdir -p /home/microsip/microservice-tests
WORKDIR /home/microsip/microservice-tests
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
