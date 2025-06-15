package com.xp.service;

import com.xp.dto.DataExportRequest;
import com.xp.dto.DataExportResponse;
import com.xp.dto.DataDeletionRequest;

/**
 * Service for LGPD compliance operations
 */
public interface LGPDComplianceService {
      /**
     * Export all user data for LGPD compliance
     * @param request Data export request
     * @return Data export response
     */
    DataExportResponse exportUserData(DataExportRequest request);
    
    /**
     * Delete user data (Right to be forgotten)
     * @param request Data deletion request
     * @return Deletion confirmation
     */
    String deleteUserData(DataDeletionRequest request);
    
    /**
     * Get user consent status
     * @param userId User ID
     * @return Consent information
     */
    String getUserConsentStatus(Long userId);
    
    /**
     * Update user consent
     * @param userId User ID
     * @param consentType Type of consent
     * @param granted Whether consent is granted
     */
    void updateUserConsent(Long userId, String consentType, boolean granted);
}
