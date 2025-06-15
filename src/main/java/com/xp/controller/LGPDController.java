package com.xp.controller;

import com.xp.dto.DataDeletionRequest;
import com.xp.dto.DataExportRequest;
import com.xp.dto.DataExportResponse;
import com.xp.service.LGPDComplianceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * LGPD Compliance Controller
 */
@RestController
@RequestMapping("/api/lgpd")
@Tag(name = "LGPD Compliance", description = "LGPD compliance and data protection APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class LGPDController {
    
    @Autowired
    private LGPDComplianceService lgpdService;
      /**
     * Export user data for LGPD compliance
     */
    @PostMapping("/export")
    @PreAuthorize("hasRole('ADMIN') or hasRole('USER')")
    @Operation(summary = "Export user data", description = "Export all user data for LGPD compliance")
    public ResponseEntity<DataExportResponse> exportUserData(@Valid @RequestBody DataExportRequest request) {
        DataExportResponse response = lgpdService.exportUserData(request);
        return ResponseEntity.ok(response);
    }
      /**
     * Delete user data (Right to be forgotten)
     */
    @PostMapping("/delete")
    @PreAuthorize("hasRole('ADMIN') or hasRole('USER')")
    @Operation(summary = "Delete user data", description = "Delete user data according to LGPD right to be forgotten")
    public ResponseEntity<Map<String, Object>> deleteUserData(@Valid @RequestBody DataDeletionRequest request) {
        String result = lgpdService.deleteUserData(request);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", result);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get user consent status
     */
    @GetMapping("/consent/{userId}")
    @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
    @Operation(summary = "Get consent status", description = "Get user consent status for data processing")
    public ResponseEntity<String> getUserConsentStatus(@PathVariable Long userId) {
        String status = lgpdService.getUserConsentStatus(userId);
        return ResponseEntity.ok(status);
    }
    
    /**
     * Update user consent
     */
    @PutMapping("/consent/{userId}")
    @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
    @Operation(summary = "Update consent", description = "Update user consent for data processing")
    public ResponseEntity<String> updateUserConsent(
            @PathVariable Long userId,
            @RequestParam String consentType,
            @RequestParam boolean granted) {
        
        lgpdService.updateUserConsent(userId, consentType, granted);
        return ResponseEntity.ok("Consent updated successfully");
    }
}
