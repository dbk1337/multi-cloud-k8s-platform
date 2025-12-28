# Spring Boot Backend Application

This is a basic Spring Boot backend application that serves as a starting point for building RESTful services.

## Project Structure

```
app
└── backend
    ├── src
    │   ├── main
    │   │   ├── java
    │   │   │   └── com
    │   │   │       └── example
    │   │   │           └── demo
    │   │   │               ├── DemoApplication.java
    │   │   │               └── controller
    │   │   │                   └── HelloController.java
    │   │   └── resources
    │   │       ├── application.properties
    │   │       └── static
    │   └── test
    │       └── java
    │           └── com
    │               └── example
    │                   └── demo
    │                       └── DemoApplicationTests.java
    ├── pom.xml
    └── README.md
```

## Setup Instructions

1. **Clone the repository**:
   ```
   git clone <repository-url>
   ```

2. **Navigate to the project directory**:
   ```
   cd app/backend
   ```

3. **Build the project**:
   ```
   mvn clean install
   ```

4. **Run the application**:
   ```
   mvn spring-boot:run
   ```

5. **Access the API**:
   Open your browser or use a tool like Postman to access the following endpoint:
   ```
   GET http://localhost:8080/hello
   ```

## Usage

This application currently has a single endpoint `/hello` that returns a greeting message. You can extend this application by adding more controllers, services, and repositories as needed.

## Dependencies

This project uses Maven for dependency management. The `pom.xml` file includes the necessary dependencies for Spring Boot.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.