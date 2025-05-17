package com.xp.factory;

import com.xp.dto.CustomerDTO;
import com.xp.model.Customer;

/**
 * Customer Factory for creating Customer objects
 * Demonstrates Factory pattern implementation
 */
public class CustomerFactory {
    
    /**
     * Create a Customer entity from a CustomerDTO
     * @param customerDTO The CustomerDTO
     * @return The Customer entity
     */
    public static Customer createCustomerEntity(CustomerDTO customerDTO) {
        Customer customer = new Customer();
        customer.setId(customerDTO.getId());
        customer.setFirstName(customerDTO.getFirstName());
        customer.setLastName(customerDTO.getLastName());
        customer.setEmail(customerDTO.getEmail());
        customer.setPhone(customerDTO.getPhone());
        customer.setAddress(customerDTO.getAddress());
        return customer;
    }
    
    /**
     * Create a CustomerDTO from a Customer entity
     * @param customer The Customer entity
     * @return The CustomerDTO
     */
    public static CustomerDTO createCustomerDTO(Customer customer) {
        CustomerDTO customerDTO = new CustomerDTO();
        customerDTO.setId(customer.getId());
        customerDTO.setFirstName(customer.getFirstName());
        customerDTO.setLastName(customer.getLastName());
        customerDTO.setEmail(customer.getEmail());
        customerDTO.setPhone(customer.getPhone());
        customerDTO.setAddress(customer.getAddress());
        return customerDTO;
    }
}
