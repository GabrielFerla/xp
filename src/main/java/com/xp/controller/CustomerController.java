package com.xp.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.xp.dto.CustomerDTO;
import com.xp.service.CustomerService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

/**
 * REST Controller for Customer operations
 */
@RestController
@RequestMapping("/api/customers")
@Tag(name = "Customer", description = "Customer management APIs")
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    /**
     * Get all customers
     * @return List of all customers
     */
    @GetMapping
    @Operation(summary = "Get all customers", description = "Returns a list of all available customers")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved customers",
                    content = @Content(schema = @Schema(implementation = CustomerDTO.class)))
    })
    public ResponseEntity<List<CustomerDTO>> getAllCustomers() {
        return ResponseEntity.ok(customerService.getAllCustomers());
    }
    
    /**
     * Get a customer by ID
     * @param id The customer ID
     * @return The customer if found
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get a customer by ID", description = "Returns a customer based on the ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved customer",
                    content = @Content(schema = @Schema(implementation = CustomerDTO.class))),
            @ApiResponse(responseCode = "404", description = "Customer not found")
    })
    public ResponseEntity<CustomerDTO> getCustomerById(@PathVariable Long id) {
        return ResponseEntity.ok(customerService.getCustomerById(id));
    }
    
    /**
     * Get customers by last name
     * @param lastName The last name to search for
     * @return List of customers with matching last name
     */
    @GetMapping("/search")
    @Operation(summary = "Get customers by last name", description = "Returns customers with matching last name")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved customers",
                    content = @Content(schema = @Schema(implementation = CustomerDTO.class)))
    })
    public ResponseEntity<List<CustomerDTO>> getCustomersByLastName(@RequestParam String lastName) {
        return ResponseEntity.ok(customerService.getCustomersByLastName(lastName));
    }
    
    /**
     * Create a new customer
     * @param customerDTO The customer data
     * @return The created customer
     */
    @PostMapping
    @Operation(summary = "Create a new customer", description = "Creates a new customer and returns it")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Customer successfully created",
                    content = @Content(schema = @Schema(implementation = CustomerDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input data")
    })
    public ResponseEntity<CustomerDTO> createCustomer(@Valid @RequestBody CustomerDTO customerDTO) {
        return new ResponseEntity<>(customerService.createCustomer(customerDTO), HttpStatus.CREATED);
    }
    
    /**
     * Update an existing customer
     * @param id The customer ID
     * @param customerDTO The updated customer data
     * @return The updated customer
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update a customer", description = "Updates a customer and returns it")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Customer successfully updated",
                    content = @Content(schema = @Schema(implementation = CustomerDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input data"),
            @ApiResponse(responseCode = "404", description = "Customer not found")
    })
    public ResponseEntity<CustomerDTO> updateCustomer(@PathVariable Long id, @Valid @RequestBody CustomerDTO customerDTO) {
        return ResponseEntity.ok(customerService.updateCustomer(id, customerDTO));
    }
    
    /**
     * Delete a customer
     * @param id The customer ID
     * @return No content
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a customer", description = "Deletes a customer by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Customer successfully deleted"),
            @ApiResponse(responseCode = "404", description = "Customer not found")
    })
    public ResponseEntity<Void> deleteCustomer(@PathVariable Long id) {
        customerService.deleteCustomer(id);
        return ResponseEntity.noContent().build();
    }
}
