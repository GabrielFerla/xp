package com.xp.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.xp.dto.CustomerDTO;
import com.xp.exception.ResourceNotFoundException;
import com.xp.factory.CustomerFactory;
import com.xp.model.Customer;
import com.xp.repository.CustomerRepository;
import com.xp.service.CustomerService;

/**
 * Service implementation for Customer operations
 */
@Service
public class CustomerServiceImpl implements CustomerService {

    @Autowired
    private CustomerRepository customerRepository;
    
    @Override
    public List<CustomerDTO> getAllCustomers() {
        return customerRepository.findAll().stream()
                .map(CustomerFactory::createCustomerDTO)
                .collect(Collectors.toList());
    }

    @Override
    public CustomerDTO getCustomerById(Long id) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + id));
        return CustomerFactory.createCustomerDTO(customer);
    }
    
    @Override
    public List<CustomerDTO> getCustomersByLastName(String lastName) {
        return customerRepository.findByLastName(lastName).stream()
                .map(CustomerFactory::createCustomerDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public CustomerDTO createCustomer(CustomerDTO customerDTO) {
        // Check if email already exists
        if (customerRepository.existsByEmail(customerDTO.getEmail())) {
            throw new IllegalArgumentException("Email already exists: " + customerDTO.getEmail());
        }
        
        Customer customer = CustomerFactory.createCustomerEntity(customerDTO);
        Customer savedCustomer = customerRepository.save(customer);
        return CustomerFactory.createCustomerDTO(savedCustomer);
    }

    @Override
    @Transactional
    public CustomerDTO updateCustomer(Long id, CustomerDTO customerDTO) {
        Customer existingCustomer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + id));
        
        // Check if email already exists for different customer
        if (!existingCustomer.getEmail().equals(customerDTO.getEmail()) 
                && customerRepository.existsByEmail(customerDTO.getEmail())) {
            throw new IllegalArgumentException("Email already exists: " + customerDTO.getEmail());
        }
        
        // Update the existing customer with new values
        existingCustomer.setFirstName(customerDTO.getFirstName());
        existingCustomer.setLastName(customerDTO.getLastName());
        existingCustomer.setEmail(customerDTO.getEmail());
        existingCustomer.setPhone(customerDTO.getPhone());
        existingCustomer.setAddress(customerDTO.getAddress());
        
        Customer updatedCustomer = customerRepository.save(existingCustomer);
        return CustomerFactory.createCustomerDTO(updatedCustomer);
    }

    @Override
    @Transactional
    public void deleteCustomer(Long id) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + id));
        customerRepository.delete(customer);
    }
}
