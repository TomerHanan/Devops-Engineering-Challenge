# BUILD STAGE
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy maven executable and project definition
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Give execution permission and fetch dependencies
RUN chmod +x mvnw 
RUN ./mvnw dependency:go-offline

# Copy source and build
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Extract jar for layered image
RUN java -Djarmode=layertools -jar target/*.jar extract --destination /app/extracted

# RUNTIME STAGE
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy layers in order
COPY --from=build /app/extracted/dependencies/ ./
COPY --from=build /app/extracted/spring-boot-loader/ ./
COPY --from=build /app/extracted/snapshot-dependencies/ ./
COPY --from=build /app/extracted/application/ ./

EXPOSE 8080

# The updated path for the Launcher in Spring Boot 3.2+
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]