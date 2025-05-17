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
   ```
   POST /api/auth/authenticate
   {
     "username": "admin",
     "password": "admin123"
   }
   ```

3. Use the returned token in the Authorization header for subsequent requests:
   ```
   Authorization: Bearer <token>
   ```

## REST API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/authenticate` - Authenticate and get JWT token

### Products

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create a new product
- `PUT /api/products/{id}` - Update a product
- `DELETE /api/products/{id}` - Delete a product

### Customers

- `GET /api/customers` - Get all customers
- `GET /api/customers/{id}` - Get customer by ID
- `GET /api/customers/search?lastName=xyz` - Search customers by last name
- `POST /api/customers` - Create a new customer
- `PUT /api/customers/{id}` - Update a customer
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
