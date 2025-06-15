package com.xp.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.security.authentication.event.AuthenticationFailureBadCredentialsEvent;
import org.springframework.security.authentication.event.AuthenticationSuccessEvent;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;

/**
 * Security audit event listener for logging authentication events
 */
@Component
@Slf4j
public class SecurityAuditEventListener {
    
    /**
     * Log successful authentication events
     * @param event Authentication success event
     */
    @EventListener
    public void handleAuthenticationSuccess(AuthenticationSuccessEvent event) {
        String username = event.getAuthentication().getName();
        String authorities = event.getAuthentication().getAuthorities().toString();
        
        log.info("SECURITY_AUDIT: AUTHENTICATION_SUCCESS - User: {} | Authorities: {} | Timestamp: {}", 
                username, authorities, LocalDateTime.now());
    }
    
    /**
     * Log failed authentication attempts
     * @param event Authentication failure event
     */    @EventListener
    public void handleAuthenticationFailure(AuthenticationFailureBadCredentialsEvent event) {
        String username = event.getAuthentication().getName();
        Object details = event.getAuthentication().getDetails();
        String clientDetails = details != null ? details.toString() : "unknown";
        
        log.warn("SECURITY_AUDIT: AUTHENTICATION_FAILURE - User: {} | Details: {} | Timestamp: {}", 
                username, clientDetails, LocalDateTime.now());
    }
    
    /**
     * Log data access events
     * @param resource Resource being accessed
     * @param action Action performed
     * @param additionalInfo Additional information
     */
    public void logDataAccess(String resource, String action, String additionalInfo) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth != null ? auth.getName() : "anonymous";
        
        log.info("SECURITY_AUDIT: DATA_ACCESS - User: {} | Resource: {} | Action: {} | Info: {} | Timestamp: {}", 
                username, resource, action, additionalInfo, LocalDateTime.now());
    }
    
    /**
     * Log security violations
     * @param violation Type of violation
     * @param details Violation details
     */
    public void logSecurityViolation(String violation, String details) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth != null ? auth.getName() : "anonymous";
        
        log.error("SECURITY_AUDIT: SECURITY_VIOLATION - User: {} | Violation: {} | Details: {} | Timestamp: {}", 
                username, violation, details, LocalDateTime.now());
    }
    
    /**
     * Log LGPD compliance events
     * @param event LGPD event type
     * @param dataSubject Data subject (user)
     * @param details Event details
     */
    public void logLGPDEvent(String event, String dataSubject, String details) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String requestor = auth != null ? auth.getName() : "system";
        
        log.info("LGPD_AUDIT: {} - Requestor: {} | DataSubject: {} | Details: {} | Timestamp: {}", 
                event, requestor, dataSubject, details, LocalDateTime.now());
    }
    
    /**
     * Log general security events
     * @param eventType Type of security event
     * @param username Username involved in the event
     * @param details Event details
     */
    public void logSecurityEvent(String eventType, String username, String details) {
        log.info("SECURITY_AUDIT: {} - User: {} | Details: {} | Timestamp: {}", 
                eventType, username, details, LocalDateTime.now());
    }
}
