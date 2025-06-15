package com.xp.security;

import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Rate limiting service to prevent brute force attacks
 */
@Component
public class RateLimitingService {
      private final ConcurrentHashMap<String, AttemptRecord> attempts = new ConcurrentHashMap<>();
    private final int MAX_ATTEMPTS = 60;  // requests per minute
    private final int LOCKOUT_DURATION_MINUTES = 15;    /**
     * Check if IP address is allowed to make requests
     * @param ipAddress Client IP address
     * @return true if allowed, false if rate limited
     */    
    public boolean isAllowed(String ipAddress) {
        AttemptRecord attemptRecord = attempts.computeIfAbsent(ipAddress, k -> new AttemptRecord());
        
        // Check if lockout period has expired
        if (attemptRecord.isLockoutExpired()) {
            attempts.remove(ipAddress);
            attemptRecord = new AttemptRecord();
            attempts.put(ipAddress, attemptRecord);
        }
        
        // Record this request attempt
        attemptRecord.incrementAttempts();
        
        return attemptRecord.getAttemptCount() <= MAX_ATTEMPTS;
    }
    
    /**
     * Record a failed attempt for an IP address
     * @param ipAddress Client IP address
     */    public void recordFailedAttempt(String ipAddress) {
        AttemptRecord attemptRecord = attempts.computeIfAbsent(ipAddress, k -> new AttemptRecord());
        attemptRecord.incrementAttempts();
    }
    
    /**
     * Clear attempts for successful authentication
     * @param ipAddress Client IP address
     */
    public void clearAttempts(String ipAddress) {
        attempts.remove(ipAddress);
    }
      /**
     * Clear all rate limiting records (for testing purposes)
     */
    public void clearAllLimits() {
        attempts.clear();
    }
    
    /**
     * Get current attempt count for an IP
     * @param ipAddress Client IP address
     * @return Current attempt count
     */
    public int getAttemptCount(String ipAddress) {
        AttemptRecord attemptRecord = attempts.get(ipAddress);
        return attemptRecord != null ? attemptRecord.getAttemptCount() : 0;
    }
    
    /**
     * Get remaining lockout time for an IP
     * @param ipAddress Client IP address
     * @return Remaining lockout time in minutes
     */    public long getRemainingLockoutTime(String ipAddress) {
        AttemptRecord attemptRecord = attempts.get(ipAddress);
        if (attemptRecord == null || attemptRecord.getAttemptCount() < MAX_ATTEMPTS) {
            return 0;
        }
        
        long minutesSinceLastAttempt = ChronoUnit.MINUTES.between(attemptRecord.getLastAttempt(), LocalDateTime.now());
        return Math.max(0, LOCKOUT_DURATION_MINUTES - minutesSinceLastAttempt);
    }
    
    /**
     * Internal class to track attempt records
     */
    private static class AttemptRecord {
        private final AtomicInteger attemptCount = new AtomicInteger(0);
        private volatile LocalDateTime lastAttempt = LocalDateTime.now();
        
        public int incrementAttempts() {
            lastAttempt = LocalDateTime.now();
            return attemptCount.incrementAndGet();
        }
        
        public int getAttemptCount() {
            return attemptCount.get();
        }
        
        public LocalDateTime getLastAttempt() {
            return lastAttempt;
        }
        
        public boolean isLockoutExpired() {
            return ChronoUnit.MINUTES.between(lastAttempt, LocalDateTime.now()) >= 15;
        }
    }
}
