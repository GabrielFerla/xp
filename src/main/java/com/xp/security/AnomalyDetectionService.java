package com.xp.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Anomaly detection service to monitor suspicious activities
 */
@Service
@Slf4j
public class AnomalyDetectionService {
    
    @Autowired
    private SecurityAuditEventListener auditLogger;
    
    private final ConcurrentHashMap<String, UserActivityRecord> userActivities = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, IpActivityRecord> ipActivities = new ConcurrentHashMap<>();
    
    // Thresholds for anomaly detection
    private static final int MAX_REQUESTS_PER_MINUTE = 100;
    private static final int MAX_FAILED_LOGINS_PER_HOUR = 10;
    private static final int MAX_DATA_ACCESS_PER_MINUTE = 50;
    
    /**
     * Monitor user activity for anomalies
     * @param username Username
     * @param activityType Type of activity
     * @param ipAddress Client IP address
     */
    public void monitorUserActivity(String username, ActivityType activityType, String ipAddress) {
        UserActivityRecord userRecord = userActivities.computeIfAbsent(username, k -> new UserActivityRecord());
        IpActivityRecord ipRecord = ipActivities.computeIfAbsent(ipAddress, k -> new IpActivityRecord());
        
        LocalDateTime now = LocalDateTime.now();
        
        // Check for suspicious patterns
        switch (activityType) {
            case LOGIN_ATTEMPT:
                if (userRecord.incrementLoginAttempts(now) > MAX_FAILED_LOGINS_PER_HOUR) {
                    reportAnomaly(username, "Excessive failed login attempts", ipAddress);
                }
                break;
                
            case DATA_ACCESS:
                if (userRecord.incrementDataAccess(now) > MAX_DATA_ACCESS_PER_MINUTE) {
                    reportAnomaly(username, "Excessive data access requests", ipAddress);
                }
                break;
                
            case API_REQUEST:
                if (ipRecord.incrementRequests(now) > MAX_REQUESTS_PER_MINUTE) {
                    reportAnomaly(username, "Excessive API requests from IP", ipAddress);
                }
                break;
        }
        
        // Check for geographical anomalies (simplified)
        if (ipRecord.isNewLocation(ipAddress)) {
            reportAnomaly(username, "Login from new geographical location", ipAddress);
        }
        
        // Check for off-hours access
        if (isOffHoursAccess(now)) {
            reportAnomaly(username, "Off-hours system access", ipAddress);
        }
    }
    
    /**
     * Report detected anomaly
     * @param username Username involved
     * @param anomalyType Type of anomaly
     * @param ipAddress Source IP address
     */
    private void reportAnomaly(String username, String anomalyType, String ipAddress) {
        String details = String.format("IP: %s | Time: %s", ipAddress, LocalDateTime.now());
        auditLogger.logSecurityViolation(anomalyType, details);
        
        log.warn("ANOMALY_DETECTED: User: {} | Type: {} | IP: {} | Time: {}", 
                username, anomalyType, ipAddress, LocalDateTime.now());
    }
    
    /**
     * Check if access is during off-hours (simplified)
     * @param time Access time
     * @return true if off-hours
     */
    private boolean isOffHoursAccess(LocalDateTime time) {
        int hour = time.getHour();
        return hour < 6 || hour > 22; // Outside 6 AM - 10 PM
    }
      /**
     * Clean up old activity records
     * @param cutoffDate Records older than this date will be removed
     */
    public void cleanupOldRecords(LocalDateTime cutoffDate) {
        log.info("Starting cleanup of activity records older than {}", cutoffDate);
        
        final AtomicInteger userRecordsRemoved = new AtomicInteger(0);
        final AtomicInteger ipRecordsRemoved = new AtomicInteger(0);
        
        // Clean up user activity records
        userActivities.entrySet().removeIf(entry -> {
            if (entry.getValue().isOlderThan(cutoffDate)) {
                userRecordsRemoved.incrementAndGet();
                return true;
            }
            return false;
        });
        
        // Clean up IP activity records
        ipActivities.entrySet().removeIf(entry -> {
            if (entry.getValue().isOlderThan(cutoffDate)) {
                ipRecordsRemoved.incrementAndGet();
                return true;
            }
            return false;
        });
        
        log.info("Cleanup completed. Removed {} user records and {} IP records", 
                userRecordsRemoved.get(), ipRecordsRemoved.get());
    }
    
    /**
     * Check if the anomaly detection service is healthy
     * @return true if service is operational
     */
    public boolean isHealthy() {
        try {
            // Basic health checks
            boolean mapsAccessible = userActivities != null && ipActivities != null;
            
            if (!mapsAccessible) {
                log.warn("Anomaly detection service maps are not accessible");
                return false;
            }
            
            // Log current status
            log.debug("Anomaly detection service health check: {} user records, {} IP records", 
                     userActivities.size(), ipActivities.size());
            
            return true;
        } catch (Exception e) {
            log.error("Health check failed for anomaly detection service", e);
            return false;
        }
    }
    
    /**
     * Get current statistics for monitoring
     * @return Statistics about current activity
     */
    public String getStatistics() {
        return String.format("Active users: %d, Active IPs: %d, Memory usage: %.2f MB",
                userActivities.size(), 
                ipActivities.size(),
                (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / (1024.0 * 1024.0));
    }
    
    /**
     * Activity types for monitoring
     */
    public enum ActivityType {
        LOGIN_ATTEMPT,
        DATA_ACCESS,
        API_REQUEST
    }
    
    /**
     * User activity tracking record
     */
    private static class UserActivityRecord {
        private final AtomicInteger loginAttempts = new AtomicInteger(0);
        private final AtomicInteger dataAccess = new AtomicInteger(0);
        private volatile LocalDateTime lastActivity = LocalDateTime.now();
        private volatile LocalDateTime hourStart = LocalDateTime.now();
        private volatile LocalDateTime minuteStart = LocalDateTime.now();
        
        public int incrementLoginAttempts(LocalDateTime now) {
            resetCountersIfNeeded(now);
            lastActivity = now;
            return loginAttempts.incrementAndGet();
        }
        
        public int incrementDataAccess(LocalDateTime now) {
            resetCountersIfNeeded(now);
            lastActivity = now;
            return dataAccess.incrementAndGet();
        }
        
        private void resetCountersIfNeeded(LocalDateTime now) {
            if (ChronoUnit.HOURS.between(hourStart, now) >= 1) {
                loginAttempts.set(0);
                hourStart = now;
            }
            if (ChronoUnit.MINUTES.between(minuteStart, now) >= 1) {
                dataAccess.set(0);
                minuteStart = now;
            }
        }
        
        public boolean isOlderThan(LocalDateTime cutoff) {
            return lastActivity.isBefore(cutoff);
        }
    }
    
    /**
     * IP activity tracking record
     */
    private static class IpActivityRecord {
        private final AtomicInteger requests = new AtomicInteger(0);
        private volatile LocalDateTime lastActivity = LocalDateTime.now();
        private volatile LocalDateTime minuteStart = LocalDateTime.now();
        private volatile boolean knownLocation = false;
        
        public int incrementRequests(LocalDateTime now) {
            if (ChronoUnit.MINUTES.between(minuteStart, now) >= 1) {
                requests.set(0);
                minuteStart = now;
            }
            lastActivity = now;
            return requests.incrementAndGet();
        }
          public boolean isNewLocation(String ipAddress) {
            // Simplified location check - in real implementation, use GeoIP
            // For now, we just mark as known after first access
            if (!knownLocation) {
                knownLocation = true;
                // In real implementation, you would check if ipAddress is from a known location
                log.debug("New location detected for IP: {}", ipAddress);
                return true;
            }
            return false;
        }
        
        public boolean isOlderThan(LocalDateTime cutoff) {
            return lastActivity.isBefore(cutoff);
        }
    }
}
