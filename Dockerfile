
# ==========================================
# Stage 1 : Application build
# ==========================================
FROM gradle:8.7-jdk21 AS build

WORKDIR /app

COPY . .

RUN chmod +x gradlew && \
    ./gradlew clean bootWar --no-daemon

# ==========================================
# Stage 2 : Production Tomcat server
# ==========================================
FROM tomcat:10.1.24-jdk21-temurin

WORKDIR /usr/local/tomcat

# Removing the default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Déploiement du jar dans Tomcat
COPY --from=build /app/build/libs/workshop-organizer-0.2.4.war \
    /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]