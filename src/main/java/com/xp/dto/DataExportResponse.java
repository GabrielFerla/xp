package com.xp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Data export response DTO for LGPD compliance
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataExportResponse {
    
    private String requestId;
    private Long userId;
    private String username;
    private String email;
    private LocalDateTime exportDate;
    private Map<String, Object> personalData;
    private Map<String, Object> userData;
    private String downloadUrl;
    private LocalDateTime expirationDate;
}
