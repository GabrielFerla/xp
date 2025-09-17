package com.xp.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.xp.model.Customer;
import com.xp.model.Product;
import com.xp.model.Role;
import com.xp.model.User;
import com.xp.repository.CustomerRepository;
import com.xp.repository.ProductRepository;
import com.xp.repository.UserRepository;

import lombok.extern.slf4j.Slf4j;

/**
 * Initial Data Loader
 */
// @Component - Temporarily disabled for MySQL testing
@Slf4j
public class DataLoader implements CommandLineRunner {

    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CustomerRepository customerRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) throws Exception {
        log.info("Loading initial data...");
        
        // Create sample products
        if (productRepository.count() == 0) {
            productRepository.save(new Product(null, "Laptop", "High-performance laptop", 1299.99, 10));
            productRepository.save(new Product(null, "Smartphone", "Latest smartphone model", 799.99, 20));
            productRepository.save(new Product(null, "Tablet", "10-inch tablet", 499.99, 15));
            productRepository.save(new Product(null, "Headphones", "Noise-cancelling headphones", 199.99, 30));
            productRepository.save(new Product(null, "Monitor", "27-inch 4K monitor", 349.99, 5));
            
            log.info("Sample products created successfully");
        }
        
        // Create sample customers
        if (customerRepository.count() == 0) {
            customerRepository.save(new Customer(null, "John", "Doe", "john.doe@example.com", "555-1234", "123 Main St"));
            customerRepository.save(new Customer(null, "Jane", "Smith", "jane.smith@example.com", "555-5678", "456 Oak Ave"));
            customerRepository.save(new Customer(null, "Michael", "Johnson", "michael.johnson@example.com", "555-9012", "789 Pine Blvd"));
            customerRepository.save(new Customer(null, "Emily", "Williams", "emily.williams@example.com", "555-3456", "321 Cedar St"));
            customerRepository.save(new Customer(null, "David", "Brown", "david.brown@example.com", "555-7890", "654 Maple Dr"));
            
            log.info("Sample customers created successfully");
        }
        
        // Create sample users
        if (userRepository.count() == 0) {
            userRepository.save(User.builder()
                    .username("admin")
                    .password(passwordEncoder.encode("admin123"))
                    .email("admin@xp.com")
                    .role(Role.ADMIN)
                    .build());
            
            userRepository.save(User.builder()
                    .username("user")
                    .password(passwordEncoder.encode("user123"))
                    .email("user@xp.com")
                    .role(Role.USER)
                    .build());
            
            log.info("Sample users created successfully");
        }
    }
}
