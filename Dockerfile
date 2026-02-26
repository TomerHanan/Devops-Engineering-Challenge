# BUILD STAGE
FROM openjdk:21-jdk-slim AS build
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline
COPY src src
RUN ./mvnw clean package -DskipTests
# Extract jar for layered image
RUN java -Djarmode=layertools -jar target/*.jar extract /app/extracted

# RUNTIME STAGE
FROM openjdk:21-jre-slim
WORKDIR /app
# Copy layers in order
COPY --from=build /app/extracted/dependencies ./
COPY --from=build /app/extracted/spring-boot-loader ./
COPY --from=build /app/extracted/snapshot-dependencies ./
COPY --from=build /app/extracted/application ./
EXPOSE 8080
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]