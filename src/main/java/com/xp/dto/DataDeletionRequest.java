package com.xp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * Data deletion request DTO for LGPD compliance
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataDeletionRequest {
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotBlank(message = "Deletion reason is required")
    private String deletionReason;
    
    private LocalDateTime requestDate;
    
    @NotBlank(message = "Requestor email is required")
    private String requestorEmail;
    
    private boolean confirmDeletion;
}
