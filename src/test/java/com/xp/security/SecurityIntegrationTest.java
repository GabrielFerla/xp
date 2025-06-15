package com.xp.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.xp.dto.DataDeletionRequest;
import com.xp.dto.DataExportRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic;

/**
 * Integration tests for security features
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Autowired
    private InputSanitizer inputSanitizer;
    
    @Autowired
    private RateLimitingService rateLimitingService;
    
    @Autowired
    private AnomalyDetectionService anomalyDetectionService;
    
    @Autowired
    private DataEncryptionService encryptionService;
    
    @Autowired
    private MFAService mfaService;
    
    @BeforeEach
    void setUp() {
        // Reset rate limiting for clean tests
        rateLimitingService.clearAllLimits();
    }
    
    @Test
    void testInputSanitization() {
        // Test XSS protection
        String maliciousInput = "<script>alert('xss')</script>Hello World";
        String sanitized = inputSanitizer.sanitizeInput(maliciousInput);
        assert !sanitized.contains("<script>");
        assert sanitized.contains("Hello World");
        
        // Test SQL injection protection
        String sqlInput = "'; DROP TABLE users; --";
        String sanitizedSql = inputSanitizer.sanitizeInput(sqlInput);
        assert !sanitizedSql.contains("DROP TABLE");
    }
    
    @Test
    void testRateLimiting() {
        String testIp = "192.168.1.100";
        
        // Should allow normal requests
        assert rateLimitingService.isAllowed(testIp);
        
        // Simulate rapid requests
        for (int i = 0; i < 65; i++) {
            rateLimitingService.isAllowed(testIp);
        }
        
        // Should be blocked after exceeding limit
        assert !rateLimitingService.isAllowed(testIp);
    }
    
    @Test
    void testDataEncryption() {
        String originalData = "Sensitive personal information";
        
        // Test encryption
        String encrypted = encryptionService.encrypt(originalData);
        assert !encrypted.equals(originalData);
        assert encryptionService.isEncrypted(encrypted);
        
        // Test decryption
        String decrypted = encryptionService.decrypt(encrypted);
        assert decrypted.equals(originalData);
        
        // Test PII encryption
        String piiEncrypted = encryptionService.encryptPII("SSN: 123-45-6789", "user_profile");
        String piiDecrypted = encryptionService.decryptPII(piiEncrypted, "user_profile");
        assert piiDecrypted.equals("SSN: 123-45-6789");
    }
    
    @Test
    void testMFAFlow() {
        String testUser = "testuser";
        
        // Generate MFA secret
        String secret = mfaService.generateMFASecret(testUser);
        assert secret != null;
        assert !secret.isEmpty();
        
        // Check MFA status
        assert mfaService.isMFAEnabled(testUser);
        
        // Generate QR code URL
        String qrUrl = mfaService.generateQRCodeURL(testUser, "XP Application");
        assert qrUrl.contains("otpauth://totp/");
        assert qrUrl.contains(testUser);
        
        // Generate backup codes
        String[] backupCodes = mfaService.generateBackupCodes(testUser);
        assert backupCodes.length == 10;
        
        // Disable MFA
        mfaService.disableMFA(testUser);
        assert !mfaService.isMFAEnabled(testUser);
    }
    
    @Test
    void testAnomalyDetection() {
        String testUser = "anomalyuser";
        String testIp = "192.168.1.200";
        
        // Normal activity should not trigger anomaly
        anomalyDetectionService.monitorUserActivity(testUser, 
                AnomalyDetectionService.ActivityType.DATA_ACCESS, testIp);
        
        // Check service health
        assert anomalyDetectionService.isHealthy();
        
        // Get statistics
        String stats = anomalyDetectionService.getStatistics();
        assert stats.contains("Active users:");
        assert stats.contains("Active IPs:");
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = "USER")
    void testLGPDDataExport() throws Exception {
        DataExportRequest request = new DataExportRequest();
        request.setUserId(1L);
        request.setRequestReason("User request for data export");
        request.setRequestorEmail("testuser@example.com");
        
        mockMvc.perform(post("/api/lgpd/export")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requestId").exists())
                .andExpect(jsonPath("$.personalData").exists())
                .andExpect(jsonPath("$.exportDate").exists());
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = "USER")
    void testLGPDDataDeletion() throws Exception {
        DataDeletionRequest request = new DataDeletionRequest();
        request.setUserId(1L);
        request.setDeletionReason("User requested account deletion");
        request.setConfirmDeletion(true);
        request.setRequestorEmail("testuser@example.com");
        
        mockMvc.perform(post("/api/lgpd/delete")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").exists());
    }
    
    @Test
    void testSecurityHeaders() throws Exception {
        mockMvc.perform(get("/api/products"))
                .andExpect(header().string("X-Frame-Options", "DENY"))
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                .andExpect(header().string("X-XSS-Protection", "1; mode=block"));
    }
    
    @Test
    void testCSRFProtection() throws Exception {
        // POST request without CSRF token should be rejected
        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"test\",\"password\":\"test\"}"))
                .andExpect(status().isForbidden());
    }
    
    @Test
    void testXSSProtection() throws Exception {
        String maliciousPayload = "<script>alert('xss')</script>";
        
        mockMvc.perform(get("/api/products")
                .param("search", maliciousPayload))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.not(
                    org.hamcrest.Matchers.containsString("<script>"))));
    }
    
    @Test
    void testSQLInjectionProtection() throws Exception {
        String sqlInjection = "'; DROP TABLE products; --";
        
        mockMvc.perform(get("/api/products")
                .param("id", sqlInjection))
                .andExpect(status().isBadRequest());
    }
    
    @Test
    @WithMockUser(username = "admin", roles = "ADMIN")
    void testAuthorizationControls() throws Exception {
        // Admin should have access to admin endpoints
        mockMvc.perform(get("/api/admin/users"))
                .andExpect(status().isOk());
    }
    
    @Test
    @WithMockUser(username = "user", roles = "USER")
    void testUserAuthorizationRestrictions() throws Exception {
        // Regular user should not have access to admin endpoints
        mockMvc.perform(get("/api/admin/users"))
                .andExpect(status().isForbidden());
    }
     
    @Test
    void testPasswordPolicy() throws Exception {
        // Test weak password rejection
        String weakPasswordPayload = """
                {
                    "username": "newuser",
                    "password": "123",
                    "email": "test@example.com"
                }
                """;
          mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(weakPasswordPayload)
                .with(csrf()))
                .andExpect(status().isBadRequest());
    }
}
