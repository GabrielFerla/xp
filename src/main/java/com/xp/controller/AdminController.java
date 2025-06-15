package com.xp.controller;

import com.xp.dto.CustomerDTO;
import com.xp.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Admin Controller for administrative functions
 */
@RestController
@RequestMapping("/api/admin")
@Tag(name = "Admin", description = "Administrative APIs")
@SecurityRequirement(name = "Bearer Authentication")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    
    @Autowired
    private CustomerService customerService;
    
    /**
     * Get all users (admin only)
     */
    @GetMapping("/users")
    @Operation(summary = "Get all users", description = "Get all users in the system (admin only)")
    public ResponseEntity<List<CustomerDTO>> getAllUsers() {
        return ResponseEntity.ok(customerService.getAllCustomers());
    }
    
    /**
     * Get system statistics
     */
    @GetMapping("/stats")
    @Operation(summary = "Get system statistics", description = "Get system statistics and metrics")
    public ResponseEntity<String> getSystemStats() {
        return ResponseEntity.ok("System statistics available");
    }
}
