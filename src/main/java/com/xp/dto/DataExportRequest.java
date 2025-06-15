package com.xp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Data export request DTO for LGPD compliance
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataExportRequest {
    
    private Long userId;
    private String requestReason;
    private LocalDateTime requestDate;
    private String requestorEmail;
}
