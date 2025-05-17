# XP Application

This is a demonstration project for Service-Oriented Architecture and Web Services, implementing both REST and SOAP web services.

## Technologies Used

- Java 21
- Spring Boot 3.4.5
- Spring Security with JWT
- Spring Data JPA
- H2 Database
- SOAP Web Services
- RESTful APIs
- OpenAPI/Swagger Documentation

## Running the Application

To run the application:

```bash
# Using Maven Wrapper
./mvnw spring-boot:run
```

Or using regular Maven:

```bash
mvn spring-boot:run
```

The application will start on port 8080 by default.

## Accessing the Application

- **H2 Database Console**: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:xpdb`
  - Username: `sa`
  - Password: `password`

- **Swagger UI**: http://localhost:8080/swagger-ui.html

- **WSDL for SOAP Web Service**: http://localhost:8080/ws/products.wsdl

## API Authentication

The REST APIs are secured with JWT authentication. To access the protected endpoints, you'll need to:

1. Register a new user or use one of the predefined users:
   - Admin: `admin` / `admin123`
   - User: `user` / `user123`

2. Authenticate to get a JWT token:
   ```json
   // POST /api/auth/authenticate
   {
     "username": "admin",
     "password": "admin123"
   }
   ```

   Response:
   ```json
   {
     "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTYzMTQ1MjQ5MCwiZXhwIjoxNjMxNDU0MjkwfQ.example_token"
   }
   ```

3. Use the returned token in the Authorization header for subsequent requests:
   ```
   Authorization: Bearer <token>
   ```

## REST API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
  ```json
  // Request Body
  {
    "firstName": "New",
    "lastName": "User",
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "securepassword123",
    "role": "USER"
  }
  ```

  Response:
  ```json
  {
    "message": "User registered successfully"
  }
  ```

- `POST /api/auth/authenticate` - Authenticate and get JWT token
  ```json
  // Request Body
  {
    "username": "admin",
    "password": "admin123"
  }
  ```

  Response:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTYzMTQ1MjQ5MCwiZXhwIjoxNjMxNDU0MjkwfQ.example_token"
  }
  ```

### Products

- `GET /api/products` - Get all products
  
  Response:
  ```json
  [
    {
      "id": 1,
      "name": "Laptop",
      "description": "High-performance laptop",
      "price": 1299.99,
      "stockQuantity": 50
    },
    {
      "id": 2,
      "name": "Smartphone",
      "description": "Latest smartphone model",
      "price": 899.99,
      "stockQuantity": 100
    }
  ]
  ```

- `GET /api/products/{id}` - Get product by ID
  
  Response:
  ```json
  {
    "id": 1,
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 1299.99,
    "stockQuantity": 50
  }
  ```

- `POST /api/products` - Create a new product
  ```json
  // Request Body
  {
    "name": "Tablet",
    "description": "10-inch tablet with high resolution display",
    "price": 499.99,
    "stockQuantity": 75
  }
  ```

- `PUT /api/products/{id}` - Update a product
  ```json
  // Request Body
  {
    "name": "Updated Laptop",
    "description": "Updated high-performance laptop",
    "price": 1399.99,
    "stockQuantity": 45
  }
  ```

- `DELETE /api/products/{id}` - Delete a product

### Customers

- `GET /api/customers` - Get all customers
  
  Response:
  ```json
  [
    {
      "id": 1,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@example.com",
      "phone": "123-456-7890",
      "address": "123 Main St"
    },
    {
      "id": 2,
      "firstName": "Jane",
      "lastName": "Smith",
      "email": "jane.smith@example.com",
      "phone": "987-654-3210",
      "address": "456 Oak Ave"
    }
  ]
  ```

- `GET /api/customers/{id}` - Get customer by ID
  
  Response:
  ```json
  {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "123-456-7890",
    "address": "123 Main St"
  }
  ```

- `GET /api/customers/search?lastName=xyz` - Search customers by last name
  
  Response:
  ```json
  [
    {
      "id": 3,
      "firstName": "Robert",
      "lastName": "xyz",
      "email": "robert.xyz@example.com",
      "phone": "555-123-4567",
      "address": "789 Pine Rd"
    }
  ]
  ```

- `POST /api/customers` - Create a new customer
  ```json
  // Request Body
  {
    "firstName": "Alice",
    "lastName": "Johnson",
    "email": "alice.johnson@example.com",
    "phone": "555-987-6543",
    "address": "321 Elm St"
  }
  ```

- `PUT /api/customers/{id}` - Update a customer
  ```json
  // Request Body
  {
    "firstName": "Alice",
    "lastName": "Williams",
    "email": "alice.williams@example.com",
    "phone": "555-987-6543",
    "address": "321 Maple Ave"
  }
  ```

- `DELETE /api/customers/{id}` - Delete a customer (admin only)

## SOAP Web Service

The application exposes a SOAP web service for products. You can access the WSDL at http://localhost:8080/ws/products.wsdl.

Sample SOAP requests are available in the `src/main/resources/soap-requests` directory.

### Testing with SoapUI or Postman

1. Import the WSDL into SoapUI or Postman
2. Use the sample requests provided in the `soap-requests` directory

### Available SOAP Operations

- `GetAllProductsRequest` - Get all products
- `GetProductRequest` - Get product by ID
- `AddProductRequest` - Add a new product

## Architectural Patterns Demonstrated

- **Service-Oriented Architecture (SOA)**: Through REST and SOAP Web Services
- **Modularization**: Using interfaces and implementations
- **Factory Pattern**: See `ProductFactory` and `CustomerFactory`
- **DTO Pattern**: Data Transfer Objects for API communication
- **Repository Pattern**: For data access abstraction
- **MVC Pattern**: Model-View-Controller pattern for web APIs

## Security Features

- JWT-based authentication and authorization
- Role-based access control
- Password encryption with BCrypt
- HTTPS-ready configuration (requires SSL certificate)

### Generating a Secure JWT Key

For security reasons, you should generate a secure JWT key for production use. The application includes a utility class to generate a secure key:

```bash
# Run the key generator
mvn compile exec:java -Dexec.mainClass="com.xp.util.JwtKeyGenerator"
```

This will output a secure key that you can add to your `application.properties` file:

```properties
jwt.secret=your_generated_secure_key_here
```
