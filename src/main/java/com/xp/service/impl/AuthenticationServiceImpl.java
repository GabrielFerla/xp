package com.xp.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.xp.dto.AuthenticationRequest;
import com.xp.dto.AuthenticationResponse;
import com.xp.dto.RegisterRequest;
import com.xp.exception.ResourceNotFoundException;
import com.xp.model.Role;
import com.xp.model.User;
import com.xp.repository.UserRepository;
import com.xp.security.JwtService;
import com.xp.security.InputSanitizer;
import com.xp.security.SecurityAuditEventListener;
import com.xp.service.AuthenticationService;

/**
 * Authentication Service implementation
 */
@Service
public class AuthenticationServiceImpl implements AuthenticationService {    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtService jwtService;
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private InputSanitizer inputSanitizer;
    
    @Autowired
    private SecurityAuditEventListener auditLogger;

    @Override
    public AuthenticationResponse register(RegisterRequest request) {
        // Sanitize input data
        String sanitizedUsername = inputSanitizer.sanitizeUsername(request.getUsername());
        String sanitizedEmail = inputSanitizer.sanitizeEmail(request.getEmail());
        
        // Check if username or email already exists
        if (Boolean.TRUE.equals(userRepository.existsByUsername(sanitizedUsername))) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (Boolean.TRUE.equals(userRepository.existsByEmail(sanitizedEmail))) {
            throw new IllegalArgumentException("Email already exists");
        }
        
        // Create new user
        var user = User.builder()
                .username(sanitizedUsername)
                .email(sanitizedEmail)
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .build();
        
        userRepository.save(user);
        
        // Log registration event
        auditLogger.logLGPDEvent("USER_REGISTRATION", sanitizedUsername, 
            "New user registered in the system");
        
        // Generate JWT token
        var jwtToken = jwtService.generateToken(user);
        
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }    @Override
    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        // Sanitize input
        String sanitizedUsername = inputSanitizer.sanitizeUsername(request.getUsername());
        
        // Authenticate user
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        sanitizedUsername,
                        request.getPassword()
                )
        );
        
        // Get user
        var user = userRepository.findByUsername(sanitizedUsername)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        // Log successful authentication
        auditLogger.logLGPDEvent("USER_LOGIN", sanitizedUsername, 
            "User successfully authenticated");
        
        // Generate JWT token
        var jwtToken = jwtService.generateToken(user);
        
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }
}
