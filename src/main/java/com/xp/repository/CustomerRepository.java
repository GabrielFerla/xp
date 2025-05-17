package com.xp.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.xp.model.Customer;

/**
 * Repository interface for Customer entity
 */
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    
    /**
     * Find customer by email
     * @param email The email to search for
     * @return The customer if found
     */
    Optional<Customer> findByEmail(String email);
    
    /**
     * Find customers by last name
     * @param lastName The last name to search for
     * @return List of customers with matching last name
     */
    List<Customer> findByLastName(String lastName);
    
    /**
     * Check if customer exists by email
     * @param email The email to check
     * @return True if exists, false otherwise
     */
    boolean existsByEmail(String email);
}
