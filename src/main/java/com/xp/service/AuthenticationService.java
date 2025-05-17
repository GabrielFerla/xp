package com.xp.service;

import com.xp.dto.AuthenticationRequest;
import com.xp.dto.AuthenticationResponse;
import com.xp.dto.RegisterRequest;

/**
 * Authentication Service interface
 */
public interface AuthenticationService {
    
    /**
     * Register a new user
     * @param request Registration request
     * @return Authentication response with JWT token
     */
    AuthenticationResponse register(RegisterRequest request);
    
    /**
     * Authenticate a user
     * @param request Authentication request
     * @return Authentication response with JWT token
     */
    AuthenticationResponse authenticate(AuthenticationRequest request);
}
