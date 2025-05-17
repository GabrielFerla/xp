package com.xp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.xp.dto.AuthenticationRequest;
import com.xp.dto.AuthenticationResponse;
import com.xp.dto.RegisterRequest;
import com.xp.service.AuthenticationService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

/**
 * Authentication Controller
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Authentication APIs")
public class AuthController {

    @Autowired
    private AuthenticationService authenticationService;

    /**
     * Register a new user
     * @param request Registration request
     * @return Authentication response with JWT token
     */
    @PostMapping("/register")
    @Operation(summary = "Register a new user", description = "Register a new user and get JWT token")
    public ResponseEntity<AuthenticationResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(authenticationService.register(request));
    }

    /**
     * Authenticate a user
     * @param request Authentication request
     * @return Authentication response with JWT token
     */
    @PostMapping("/authenticate")
    @Operation(summary = "Authenticate a user", description = "Authenticate a user and get JWT token")
    public ResponseEntity<AuthenticationResponse> authenticate(
            @Valid @RequestBody AuthenticationRequest request
    ) {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }
}
