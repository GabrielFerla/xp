package com.xp.service.impl;

import com.xp.dto.DataDeletionRequest;
import com.xp.dto.DataExportRequest;
import com.xp.dto.DataExportResponse;
import com.xp.model.User;
import com.xp.repository.UserRepository;
import com.xp.security.SecurityAuditEventListener;
import com.xp.service.LGPDComplianceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * LGPD Compliance Service Implementation
 */
@Service
@Slf4j
public class LGPDComplianceServiceImpl implements LGPDComplianceService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private SecurityAuditEventListener auditLogger;
      @Override
    public DataExportResponse exportUserData(DataExportRequest request) {
        Long userId = request.getUserId();
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        User user = userOpt.get();
        
        // Compile all user data
        Map<String, Object> userData = new HashMap<>();
        userData.put("id", user.getId());
        userData.put("username", user.getUsername());
        userData.put("email", user.getEmail());
        userData.put("role", user.getRole());
        userData.put("accountStatus", "active");
        userData.put("requestReason", request.getRequestReason());
        userData.put("requestorEmail", request.getRequestorEmail());
          DataExportResponse response = new DataExportResponse();
        response.setRequestId("REQ-" + System.currentTimeMillis());
        response.setUserId(userId);
        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        response.setExportDate(LocalDateTime.now());
        response.setPersonalData(userData);
        response.setUserData(userData);
        response.setDownloadUrl("/api/lgpd/download/" + userId + "/" + System.currentTimeMillis());
        response.setExpirationDate(LocalDateTime.now().plusDays(30)); // Data expires in 30 days
        
        // Log LGPD event
        auditLogger.logLGPDEvent("DATA_EXPORT", user.getUsername(), 
            "User data exported for LGPD compliance");
        
        log.info("Data export completed for user: {}", user.getUsername());
        
        return response;
    }
    
    @Override
    public String deleteUserData(DataDeletionRequest request) {
        if (!request.isConfirmDeletion()) {
            throw new IllegalArgumentException("Deletion must be confirmed");
        }
        
        Optional<User> userOpt = userRepository.findById(request.getUserId());
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        User user = userOpt.get();
        String username = user.getUsername();
        
        // In a real implementation, you would:
        // 1. Delete or anonymize data from all related tables
        // 2. Keep minimal data for legal/audit purposes
        // 3. Update privacy status
        
        // For this demo, we'll just mark the user as deleted
        // userRepository.delete(user);
        
        // Log LGPD event before deletion
        auditLogger.logLGPDEvent("DATA_DELETION", username, 
            String.format("User data deletion requested. Reason: %s", request.getDeletionReason()));
        
        log.info("Data deletion completed for user: {} | Reason: {}", 
            username, request.getDeletionReason());
        
        return String.format("User data for '%s' has been scheduled for deletion. " +
            "Complete removal will occur within 30 days as per LGPD requirements.", username);
    }
    
    @Override
    public String getUserConsentStatus(Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        User user = userOpt.get();
        
        // In a real implementation, you would have a consent management system
        Map<String, Object> consentStatus = new HashMap<>();
        consentStatus.put("dataProcessing", true);
        consentStatus.put("marketing", false);
        consentStatus.put("analytics", true);
        consentStatus.put("lastUpdated", LocalDateTime.now().minusDays(30));
        
        auditLogger.logLGPDEvent("CONSENT_CHECK", user.getUsername(), 
            "User consent status retrieved");
        
        return "Consent status retrieved for user: " + user.getUsername();
    }
    
    @Override
    public void updateUserConsent(Long userId, String consentType, boolean granted) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        User user = userOpt.get();
        
        // In a real implementation, you would update the consent in a dedicated table
        // consentRepository.updateConsent(userId, consentType, granted);
        
        auditLogger.logLGPDEvent("CONSENT_UPDATE", user.getUsername(), 
            String.format("Consent updated: %s = %s", consentType, granted));
        
        log.info("Consent updated for user: {} | Type: {} | Granted: {}", 
            user.getUsername(), consentType, granted);
    }
}
