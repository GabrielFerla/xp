package com.xp.esb.config;

import org.apache.camel.AggregationStrategy;
import org.apache.camel.Exchange;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

/**
 * Message Enrichment Aggregation Strategy for ESB
 * Enriches messages with additional data from external services
 */
@Slf4j
public class MessageEnrichmentAggregationStrategy implements AggregationStrategy {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Exchange aggregate(Exchange oldExchange, Exchange newExchange) {
        log.info("ESB: Enriching message with additional data");

        try {
            Map<String, Object> enrichedMessage = new HashMap<>();
            enrichedMessage.put("timestamp", System.currentTimeMillis());
            enrichedMessage.put("source", "ESB-Enricher");

            // Process original message
            if (oldExchange != null) {
                String originalBody = oldExchange.getIn().getBody(String.class);
                try {
                    JsonNode originalJson = objectMapper.readTree(originalBody);
                    enrichedMessage.put("originalMessage", originalJson);
                } catch (Exception e) {
                    enrichedMessage.put("originalMessage", originalBody);
                }
            }

            // Process enrichment data
            if (newExchange != null) {
                String enrichmentData = newExchange.getIn().getBody(String.class);
                try {
                    JsonNode enrichmentJson = objectMapper.readTree(enrichmentData);
                    enrichedMessage.put("enrichmentData", enrichmentJson);
                } catch (Exception e) {
                    enrichedMessage.put("enrichmentData", enrichmentData);
                }
            }

            enrichedMessage.put("status", "enriched");

            String jsonResponse = objectMapper.writeValueAsString(enrichedMessage);
            
            if (oldExchange != null) {
                oldExchange.getIn().setBody(jsonResponse);
                return oldExchange;
            } else {
                newExchange.getIn().setBody(jsonResponse);
                return newExchange;
            }

        } catch (Exception e) {
            log.error("Error during message enrichment", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Message enrichment failed");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("status", "error");

            try {
                String jsonError = objectMapper.writeValueAsString(errorResponse);
                if (oldExchange != null) {
                    oldExchange.getIn().setBody(jsonError);
                    return oldExchange;
                } else {
                    newExchange.getIn().setBody(jsonError);
                    return newExchange;
                }
            } catch (Exception jsonException) {
                log.error("Failed to create error response", jsonException);
                return oldExchange != null ? oldExchange : newExchange;
            }
        }
    }
}
