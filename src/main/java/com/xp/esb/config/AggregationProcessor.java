package com.xp.esb.config;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

/**
 * Aggregation Processor for ESB
 * Combines multiple service responses into a single response
 */
@Slf4j
public class AggregationProcessor implements Processor {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void process(Exchange exchange) throws Exception {
        log.info("ESB: Aggregating multiple service responses");

        Map<String, Object> aggregatedResponse = new HashMap<>();
        aggregatedResponse.put("timestamp", System.currentTimeMillis());
        aggregatedResponse.put("source", "ESB-Aggregator");

        try {
            // Get the aggregated exchanges
            @SuppressWarnings("unchecked")
            java.util.List<Exchange> exchanges = (java.util.List<Exchange>) exchange.getProperty("CamelAggregatedExchanges");

            if (exchanges != null && !exchanges.isEmpty()) {
                for (int i = 0; i < exchanges.size(); i++) {
                    Exchange ex = exchanges.get(i);
                    String responseBody = ex.getIn().getBody(String.class);
                    
                    try {
                        JsonNode jsonNode = objectMapper.readTree(responseBody);
                        
                        // Determine response type and add to aggregated response
                        if (responseBody.contains("products") || responseBody.contains("ProductSoap")) {
                            aggregatedResponse.put("products", jsonNode);
                        } else if (responseBody.contains("customers") || responseBody.contains("firstName")) {
                            aggregatedResponse.put("customers", jsonNode);
                        } else {
                            aggregatedResponse.put("response_" + i, jsonNode);
                        }
                        
                    } catch (Exception e) {
                        log.warn("Failed to parse response as JSON: {}", responseBody);
                        aggregatedResponse.put("response_" + i, responseBody);
                    }
                }
            }

            aggregatedResponse.put("totalResponses", exchanges != null ? exchanges.size() : 0);
            aggregatedResponse.put("status", "success");

        } catch (Exception e) {
            log.error("Error during aggregation", e);
            aggregatedResponse.put("error", "Aggregation failed");
            aggregatedResponse.put("message", e.getMessage());
            aggregatedResponse.put("status", "error");
        }

        String jsonResponse = objectMapper.writeValueAsString(aggregatedResponse);
        exchange.getIn().setBody(jsonResponse);
    }
}
