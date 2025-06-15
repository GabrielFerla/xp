package com.xp.security;

import com.xp.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Multi-Factor Authentication (MFA) service
 * Implements TOTP (Time-based One-Time Password) algorithm
 */
@Service
public class MFAService {
    
    private static final Logger logger = LoggerFactory.getLogger(MFAService.class);
    
    @Autowired
    private SecurityAuditEventListener auditLogger;
    
    private static final String HMAC_ALGORITHM = "HmacSHA1";
    private static final int TIME_STEP = 30; // 30 seconds
    private static final int CODE_DIGITS = 6;
    private static final int WINDOW = 1; // Allow 1 time step before/after current
    
    // Store MFA secrets per user (in production, store in database)
    private final ConcurrentHashMap<String, String> userMfaSecrets = new ConcurrentHashMap<>();
    
    // Store used codes to prevent replay attacks
    private final ConcurrentHashMap<String, Long> usedCodes = new ConcurrentHashMap<>();
    
    /**
     * Generate MFA secret for a user
     * @param username Username
     * @return Base32 encoded secret
     */
    public String generateMFASecret(String username) {
        SecureRandom random = new SecureRandom();
        byte[] secret = new byte[20]; // 160 bits
        random.nextBytes(secret);
        
        String base32Secret = Base64.getEncoder().encodeToString(secret);
        userMfaSecrets.put(username, base32Secret);
        
        auditLogger.logSecurityEvent("MFA_SECRET_GENERATED", username, "MFA secret generated for user");
        logger.info("MFA secret generated for user: {}", username);
        
        return base32Secret;
    }
    
    /**
     * Generate QR code URL for MFA setup
     * @param username Username
     * @param issuer Application name
     * @return QR code URL for authenticator apps
     */
    public String generateQRCodeURL(String username, String issuer) {
        String secret = userMfaSecrets.get(username);
        if (secret == null) {
            secret = generateMFASecret(username);
        }
        
        return String.format(
            "otpauth://totp/%s:%s?secret=%s&issuer=%s&digits=%d&period=%d",
            issuer, username, secret, issuer, CODE_DIGITS, TIME_STEP
        );
    }
    
    /**
     * Verify MFA code
     * @param username Username
     * @param code User-provided MFA code
     * @return true if code is valid
     */
    public boolean verifyMFACode(String username, String code) {
        String secret = userMfaSecrets.get(username);
        if (secret == null) {
            auditLogger.logSecurityEvent("MFA_VERIFY_FAILED", username, "No MFA secret found");
            return false;
        }
        
        // Check if code was already used
        String codeKey = username + ":" + code;
        if (usedCodes.containsKey(codeKey)) {
            auditLogger.logSecurityEvent("MFA_REPLAY_ATTEMPT", username, "MFA code replay attempt");
            return false;
        }
        
        long currentTime = Instant.now().getEpochSecond() / TIME_STEP;
        
        // Check current time window and adjacent windows
        for (int i = -WINDOW; i <= WINDOW; i++) {
            long timeSlot = currentTime + i;
            String expectedCode = generateTOTP(secret, timeSlot);
            
            if (code.equals(expectedCode)) {
                // Mark code as used
                usedCodes.put(codeKey, timeSlot);
                
                // Clean up old used codes (older than 2 minutes)
                cleanupUsedCodes(currentTime - 4); // 4 * 30 seconds = 2 minutes
                
                auditLogger.logSecurityEvent("MFA_VERIFY_SUCCESS", username, "MFA code verified successfully");
                return true;
            }
        }
        
        auditLogger.logSecurityEvent("MFA_VERIFY_FAILED", username, "Invalid MFA code provided");
        return false;
    }
    
    /**
     * Check if user has MFA enabled
     * @param username Username
     * @return true if MFA is enabled
     */
    public boolean isMFAEnabled(String username) {
        return userMfaSecrets.containsKey(username);
    }
    
    /**
     * Disable MFA for a user
     * @param username Username
     */
    public void disableMFA(String username) {
        userMfaSecrets.remove(username);
        
        // Clean up used codes for this user
        usedCodes.entrySet().removeIf(entry -> entry.getKey().startsWith(username + ":"));
        
        auditLogger.logSecurityEvent("MFA_DISABLED", username, "MFA disabled for user");
        logger.info("MFA disabled for user: {}", username);
    }
    
    /**
     * Generate TOTP code
     * @param secret Base64 encoded secret
     * @param timeSlot Time slot for TOTP
     * @return Generated TOTP code
     */
    private String generateTOTP(String secret, long timeSlot) {
        try {
            byte[] secretBytes = Base64.getDecoder().decode(secret);
            byte[] timeBytes = ByteBuffer.allocate(8).putLong(timeSlot).array();
            
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(secretBytes, HMAC_ALGORITHM);
            mac.init(keySpec);
            
            byte[] hash = mac.doFinal(timeBytes);
            
            int offset = hash[hash.length - 1] & 0x0F;
            int code = ((hash[offset] & 0x7F) << 24) |
                      ((hash[offset + 1] & 0xFF) << 16) |
                      ((hash[offset + 2] & 0xFF) << 8) |
                      (hash[offset + 3] & 0xFF);
            
            code = code % (int) Math.pow(10, CODE_DIGITS);
            
            return String.format("%0" + CODE_DIGITS + "d", code);
            
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            logger.error("Error generating TOTP code", e);
            throw new RuntimeException("Failed to generate TOTP code", e);
        }
    }
    
    /**
     * Clean up old used codes
     * @param cutoffTime Time before which codes should be removed
     */
    private void cleanupUsedCodes(long cutoffTime) {
        usedCodes.entrySet().removeIf(entry -> entry.getValue() < cutoffTime);
    }
    
    /**
     * Generate backup codes for MFA recovery
     * @param username Username
     * @return List of backup codes
     */
    public String[] generateBackupCodes(String username) {
        SecureRandom random = new SecureRandom();
        String[] backupCodes = new String[10];
        
        for (int i = 0; i < backupCodes.length; i++) {
            // Generate 8-digit backup code
            int code = random.nextInt(90000000) + 10000000;
            backupCodes[i] = String.valueOf(code);
        }
        
        // In production, store these encrypted in database
        auditLogger.logSecurityEvent("MFA_BACKUP_CODES_GENERATED", username, "Backup codes generated");
        logger.info("Backup codes generated for user: {}", username);
        
        return backupCodes;
    }
    
    /**
     * Get MFA status for user
     * @param username Username
     * @return MFA status information
     */
    public MFAStatus getMFAStatus(String username) {
        boolean enabled = isMFAEnabled(username);
        return new MFAStatus(enabled, enabled ? "MFA is enabled" : "MFA is not enabled");
    }
    
    /**
     * MFA status information
     */
    public static class MFAStatus {
        private final boolean enabled;
        private final String status;
        
        public MFAStatus(boolean enabled, String status) {
            this.enabled = enabled;
            this.status = status;
        }
        
        public boolean isEnabled() {
            return enabled;
        }
        
        public String getStatus() {
            return status;
        }
    }
}
