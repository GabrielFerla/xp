package com.xp.security;

import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Input sanitization utility to prevent XSS and injection attacks
 */
@Component
public class InputSanitizer {
    
    private static final Pattern HTML_TAG_PATTERN = Pattern.compile("<[^>]*>");
    private static final Pattern SCRIPT_PATTERN = Pattern.compile("(?i)<script[^>]*>.*?</script>");
    private static final Pattern SQL_INJECTION_PATTERN = Pattern.compile("(?i)(union|select|insert|update|delete|drop|create|alter|exec|execute)");
    
    /**
     * Sanitize input to prevent XSS attacks
     * @param input The input string to sanitize
     * @return Sanitized string
     */    public String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        
        // Remove script tags
        String sanitized = SCRIPT_PATTERN.matcher(input).replaceAll("");
        
        // Remove HTML tags
        sanitized = HTML_TAG_PATTERN.matcher(sanitized).replaceAll("");
        
        // Remove SQL injection patterns
        sanitized = SQL_INJECTION_PATTERN.matcher(sanitized).replaceAll("");
        
        // Escape special characters
        sanitized = sanitized
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;");
        
        return sanitized.trim();
    }
    
    /**
     * Check for potential SQL injection patterns
     * @param input The input to check
     * @return true if suspicious patterns are found
     */
    public boolean containsSqlInjectionPattern(String input) {
        if (input == null) {
            return false;
        }
        return SQL_INJECTION_PATTERN.matcher(input).find();
    }
    
    /**
     * Validate and sanitize email input
     * @param email Email to validate
     * @return Sanitized email
     * @throws IllegalArgumentException if email is invalid
     */
    public String sanitizeEmail(String email) {
        if (email == null) {
            return null;
        }
        
        String sanitized = sanitizeInput(email);
        
        // Basic email validation
        if (!sanitized.matches("^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        
        return sanitized;
    }
    
    /**
     * Sanitize username input
     * @param username Username to sanitize
     * @return Sanitized username
     */
    public String sanitizeUsername(String username) {
        if (username == null) {
            return null;
        }
        
        // Allow only alphanumeric characters, underscores, and hyphens
        String sanitized = username.replaceAll("[^a-zA-Z0-9_-]", "");
        
        if (sanitized.length() < 3 || sanitized.length() > 50) {
            throw new IllegalArgumentException("Username must be between 3 and 50 characters");
        }
        
        return sanitized;
    }
}
