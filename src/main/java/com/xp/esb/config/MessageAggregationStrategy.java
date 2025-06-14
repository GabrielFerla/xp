package com.xp.esb.config;

import org.apache.camel.AggregationStrategy;
import org.apache.camel.Exchange;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Message Aggregation Strategy for ESB
 * Aggregates multiple service responses into a single consolidated response
 */
@Slf4j
public class MessageAggregationStrategy implements AggregationStrategy {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Exchange aggregate(Exchange oldExchange, Exchange newExchange) {
        log.info("ESB: Aggregating messages");

        try {
            Map<String, Object> aggregatedMessage = new HashMap<>();
            List<Object> responses = new ArrayList<>();

            // Initialize aggregation metadata
            aggregatedMessage.put("timestamp", System.currentTimeMillis());
            aggregatedMessage.put("source", "ESB-Aggregator");
            aggregatedMessage.put("totalResponses", 0);

            // Process first/existing exchange
            if (oldExchange != null) {
                String oldBody = oldExchange.getIn().getBody(String.class);
                if (oldBody != null) {
                    try {
                        // Check if it's already an aggregated message
                        JsonNode oldJson = objectMapper.readTree(oldBody);
                        if (oldJson.has("responses")) {
                            // Extract existing responses
                            JsonNode existingResponses = oldJson.get("responses");
                            if (existingResponses.isArray()) {
                                existingResponses.forEach(responses::add);
                            }
                        } else {
                            // Add as new response
                            responses.add(oldJson);
                        }
                    } catch (Exception e) {
                        // If parsing fails, add as string
                        responses.add(oldBody);
                    }
                }
            }

            // Process new exchange
            if (newExchange != null) {
                String newBody = newExchange.getIn().getBody(String.class);
                if (newBody != null) {
                    try {
                        JsonNode newJson = objectMapper.readTree(newBody);
                        responses.add(newJson);
                    } catch (Exception e) {
                        // If parsing fails, add as string
                        responses.add(newBody);
                    }
                }
            }

            // Build aggregated response
            aggregatedMessage.put("responses", responses);
            aggregatedMessage.put("totalResponses", responses.size());
            aggregatedMessage.put("status", "aggregated");

            String jsonResponse = objectMapper.writeValueAsString(aggregatedMessage);
            
            // Return the exchange with aggregated body
            Exchange resultExchange = oldExchange != null ? oldExchange : newExchange;
            if (resultExchange != null) {
                resultExchange.getIn().setBody(jsonResponse);
            }
            
            return resultExchange;

        } catch (Exception e) {
            log.error("Error during message aggregation", e);
            
            // Create error response
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Message aggregation failed");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("status", "error");
            errorResponse.put("timestamp", System.currentTimeMillis());

            try {
                String jsonError = objectMapper.writeValueAsString(errorResponse);
                Exchange resultExchange = oldExchange != null ? oldExchange : newExchange;
                if (resultExchange != null) {
                    resultExchange.getIn().setBody(jsonError);
                }
                return resultExchange;
            } catch (Exception jsonException) {
                log.error("Failed to create error response", jsonException);
                return oldExchange != null ? oldExchange : newExchange;
            }
        }
    }
}
