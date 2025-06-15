package com.xp.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Service for encrypting sensitive data at rest
 * Uses AES-256-GCM for authenticated encryption
 */
@Service
public class DataEncryptionService {
    
    private static final Logger logger = LoggerFactory.getLogger(DataEncryptionService.class);
    
    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 16;
    
    @Value("${app.encryption.key:#{null}}")
    private String encryptionKeyBase64;
    
    private SecretKey encryptionKey;
    private final SecureRandom secureRandom = new SecureRandom();
    
    /**
     * Initialize encryption key
     */
    private SecretKey getEncryptionKey() {
        if (encryptionKey == null) {
            if (encryptionKeyBase64 != null && !encryptionKeyBase64.isEmpty()) {
                // Use configured key
                byte[] keyBytes = Base64.getDecoder().decode(encryptionKeyBase64);
                encryptionKey = new SecretKeySpec(keyBytes, ALGORITHM);
            } else {
                // Generate new key (in production, this should be loaded from secure storage)
                try {
                    KeyGenerator keyGenerator = KeyGenerator.getInstance(ALGORITHM);
                    keyGenerator.init(256);
                    encryptionKey = keyGenerator.generateKey();
                    
                    // Log the key for configuration (ONLY for development)
                    String keyBase64 = Base64.getEncoder().encodeToString(encryptionKey.getEncoded());
                    logger.warn("Generated new encryption key. Add to configuration: app.encryption.key={}", keyBase64);
                } catch (Exception e) {
                    throw new RuntimeException("Failed to generate encryption key", e);
                }
            }
        }
        return encryptionKey;
    }
    
    /**
     * Encrypt sensitive data
     * @param plaintext The data to encrypt
     * @return Base64 encoded encrypted data with IV
     */
    public String encrypt(String plaintext) {
        if (plaintext == null || plaintext.isEmpty()) {
            return plaintext;
        }
        
        try {
            // Generate random IV
            byte[] iv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(iv);
            
            // Initialize cipher
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv);
            cipher.init(Cipher.ENCRYPT_MODE, getEncryptionKey(), parameterSpec);
            
            // Encrypt the data
            byte[] encryptedData = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            
            // Combine IV and encrypted data
            byte[] encryptedWithIv = new byte[GCM_IV_LENGTH + encryptedData.length];
            System.arraycopy(iv, 0, encryptedWithIv, 0, GCM_IV_LENGTH);
            System.arraycopy(encryptedData, 0, encryptedWithIv, GCM_IV_LENGTH, encryptedData.length);
            
            return Base64.getEncoder().encodeToString(encryptedWithIv);
            
        } catch (Exception e) {
            logger.error("Failed to encrypt data", e);
            throw new RuntimeException("Encryption failed", e);
        }
    }
    
    /**
     * Decrypt sensitive data
     * @param encryptedData Base64 encoded encrypted data with IV
     * @return Decrypted plaintext
     */
    public String decrypt(String encryptedData) {
        if (encryptedData == null || encryptedData.isEmpty()) {
            return encryptedData;
        }
        
        try {
            // Decode from Base64
            byte[] encryptedWithIv = Base64.getDecoder().decode(encryptedData);
            
            // Extract IV and encrypted data
            byte[] iv = new byte[GCM_IV_LENGTH];
            byte[] encrypted = new byte[encryptedWithIv.length - GCM_IV_LENGTH];
            System.arraycopy(encryptedWithIv, 0, iv, 0, GCM_IV_LENGTH);
            System.arraycopy(encryptedWithIv, GCM_IV_LENGTH, encrypted, 0, encrypted.length);
            
            // Initialize cipher for decryption
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv);
            cipher.init(Cipher.DECRYPT_MODE, getEncryptionKey(), parameterSpec);
            
            // Decrypt the data
            byte[] decryptedData = cipher.doFinal(encrypted);
            
            return new String(decryptedData, StandardCharsets.UTF_8);
            
        } catch (Exception e) {
            logger.error("Failed to decrypt data", e);
            throw new RuntimeException("Decryption failed", e);
        }
    }
    
    /**
     * Encrypt PII data with additional context
     * @param piiData Personal identifiable information
     * @param context Additional context for audit trail
     * @return Encrypted PII data
     */
    public String encryptPII(String piiData, String context) {
        logger.debug("Encrypting PII data for context: {}", context);
        return encrypt(piiData);
    }
    
    /**
     * Decrypt PII data with additional context
     * @param encryptedPiiData Encrypted personal identifiable information
     * @param context Additional context for audit trail
     * @return Decrypted PII data
     */
    public String decryptPII(String encryptedPiiData, String context) {
        logger.debug("Decrypting PII data for context: {}", context);
        return decrypt(encryptedPiiData);
    }
    
    /**
     * Check if data appears to be encrypted
     * @param data Data to check
     * @return true if data appears to be encrypted
     */
    public boolean isEncrypted(String data) {
        if (data == null || data.length() < 16) {
            return false;
        }
        
        try {
            // Try to decode as Base64
            Base64.getDecoder().decode(data);
            // If it decodes and has minimum length, likely encrypted
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
    
    /**
     * Generate a new encryption key for configuration
     * @return Base64 encoded encryption key
     */
    public static String generateNewEncryptionKey() {
        try {
            KeyGenerator keyGenerator = KeyGenerator.getInstance(ALGORITHM);
            keyGenerator.init(256);
            SecretKey key = keyGenerator.generateKey();
            return Base64.getEncoder().encodeToString(key.getEncoded());
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate encryption key", e);
        }
    }
}
