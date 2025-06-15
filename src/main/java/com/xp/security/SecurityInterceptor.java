package com.xp.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Security interceptor for monitoring and logging requests
 */
@Component
@Slf4j
public class SecurityInterceptor implements HandlerInterceptor {
    
    private static final String ANONYMOUS_USER = "anonymous";
    
    @Autowired
    private AnomalyDetectionService anomalyDetectionService;
    
    @Autowired
    private RateLimitingService rateLimitingService;
    
    @Autowired
    private SecurityAuditEventListener auditLogger;
    
    @Autowired
    private InputSanitizer inputSanitizer;
      @Override
    public boolean preHandle(@NonNull HttpServletRequest request, 
                           @Nullable HttpServletResponse response, 
                           @NonNull Object handler) throws Exception {
        
        String ipAddress = getClientIpAddress(request);
        String userAgent = request.getHeader("User-Agent");
        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        
        // Check rate limiting
        if (!rateLimitingService.isAllowed(ipAddress)) {
            long remainingTime = rateLimitingService.getRemainingLockoutTime(ipAddress);
            if (response != null) {
                response.setStatus(429); // HTTP 429 Too Many Requests
                response.setHeader("Retry-After", String.valueOf(remainingTime * 60));
            }
            
            auditLogger.logSecurityViolation("RATE_LIMIT_EXCEEDED", 
                String.format("IP: %s | URI: %s | Remaining lockout: %d minutes", 
                    ipAddress, requestUri, remainingTime));
            return false;
        }
        
        // Get authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth != null ? auth.getName() : ANONYMOUS_USER;
        
        // Monitor for anomalies
        if (requestUri.startsWith("/api/")) {
            anomalyDetectionService.monitorUserActivity(username, 
                AnomalyDetectionService.ActivityType.API_REQUEST, ipAddress);
        }
        
        // Check for suspicious user agents
        if (userAgent != null && isSuspiciousUserAgent(userAgent)) {
            auditLogger.logSecurityViolation("SUSPICIOUS_USER_AGENT", 
                String.format("User: %s | IP: %s | UserAgent: %s", username, ipAddress, userAgent));
        }
        
        // Validate query parameters for injection attacks
        request.getParameterMap().forEach((paramName, paramValues) -> {
            for (String paramValue : paramValues) {
                if (inputSanitizer.containsSqlInjectionPattern(paramValue)) {
                    auditLogger.logSecurityViolation("SQL_INJECTION_ATTEMPT", 
                        String.format("User: %s | IP: %s | Parameter: %s | Value: %s", 
                            username, ipAddress, paramName, paramValue));
                }
            }
        });
        
        // Log request for audit
        auditLogger.logDataAccess(requestUri, method, 
            String.format("User: %s | IP: %s", username, ipAddress));
        
        return true;
    }
      @Override
    public void afterCompletion(@NonNull HttpServletRequest request, 
                              @Nullable HttpServletResponse response, 
                              @NonNull Object handler, @Nullable Exception ex) throws Exception {
        
        // Log any exceptions for security analysis
        if (ex != null) {
            String ipAddress = getClientIpAddress(request);
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth != null ? auth.getName() : ANONYMOUS_USER;
            
            auditLogger.logSecurityViolation("REQUEST_EXCEPTION", 
                String.format("User: %s | IP: %s | Exception: %s", 
                    username, ipAddress, ex.getMessage()));
        }
        
        // Log response status for monitoring
        if (response != null) {
            int status = response.getStatus();
            if (status >= 400) {
                String ipAddress = getClientIpAddress(request);
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                String username = auth != null ? auth.getName() : ANONYMOUS_USER;
                
                if (status == 401 || status == 403) {
                    rateLimitingService.recordFailedAttempt(ipAddress);
                    anomalyDetectionService.monitorUserActivity(username, 
                        AnomalyDetectionService.ActivityType.LOGIN_ATTEMPT, ipAddress);
                }
            }
        }
    }
    
    /**
     * Extract client IP address from request
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * Check for suspicious user agent patterns
     */
    private boolean isSuspiciousUserAgent(String userAgent) {
        String lowerUserAgent = userAgent.toLowerCase();
        return lowerUserAgent.contains("sqlmap") ||
               lowerUserAgent.contains("nikto") ||
               lowerUserAgent.contains("nmap") ||
               lowerUserAgent.contains("burp") ||
               lowerUserAgent.contains("owasp") ||
               lowerUserAgent.contains("scanner") ||
               lowerUserAgent.contains("bot") && !lowerUserAgent.contains("googlebot");
    }
}
