package com.xp.service;

import java.util.List;

import com.xp.dto.CustomerDTO;

/**
 * Service interface for Customer operations
 */
public interface CustomerService {
    
    /**
     * Get all customers
     * @return List of all customers
     */
    List<CustomerDTO> getAllCustomers();
    
    /**
     * Get a customer by its ID
     * @param id The customer ID
     * @return The customer if found
     */
    CustomerDTO getCustomerById(Long id);
    
    /**
     * Get customers by last name
     * @param lastName The last name to search for
     * @return List of customers with matching last name
     */
    List<CustomerDTO> getCustomersByLastName(String lastName);
    
    /**
     * Create a new customer
     * @param customerDTO The customer data
     * @return The created customer
     */
    CustomerDTO createCustomer(CustomerDTO customerDTO);
    
    /**
     * Update an existing customer
     * @param id The customer ID
     * @param customerDTO The updated customer data
     * @return The updated customer
     */
    CustomerDTO updateCustomer(Long id, CustomerDTO customerDTO);
    
    /**
     * Delete a customer
     * @param id The customer ID
     */
    void deleteCustomer(Long id);
}
