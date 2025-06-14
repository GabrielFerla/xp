package com.xp.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.util.HashMap;
import java.util.Map;

/**
 * ESB Controller - Demonstrates Enterprise Service Bus capabilities
 */
@RestController
@RequestMapping("/api/esb")
@Tag(name = "ESB", description = "Enterprise Service Bus demonstration APIs")
public class ESBController {

    /**
     * Get ESB information and available routes
     */
    @GetMapping("/info")
    @Operation(summary = "Get ESB information", description = "Returns information about ESB routes and capabilities")
    public ResponseEntity<Map<String, Object>> getESBInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "XP Application ESB");
        info.put("description", "Enterprise Service Bus using Apache Camel");
        info.put("version", "1.0.0");
        
        Map<String, String> routes = new HashMap<>();
        routes.put("/esb/api-to-soap", "REST to SOAP Bridge - Transforms REST calls to SOAP");
        routes.put("/esb/aggregate", "Message Aggregation - Combines multiple service responses");
        routes.put("/esb/route", "Content-based Router - Routes based on entity type");
        routes.put("/esb/loadbalance", "Load Balancer - Distributes load between services");
        routes.put("/esb/circuit-breaker", "Circuit Breaker - Provides fallback for failed services");
        routes.put("/esb/enrich", "Message Enricher - Enriches messages with additional data");
        routes.put("/esb/deadletter", "Dead Letter Channel - Handles failed message processing");
        
        info.put("availableRoutes", routes);
        
        Map<String, String> patterns = new HashMap<>();
        patterns.put("Message Router", "Routes messages based on content");
        patterns.put("Message Translator", "Transforms message formats (SOAP to JSON)");
        patterns.put("Message Aggregator", "Combines multiple messages");
        patterns.put("Load Balancer", "Distributes load across endpoints");
        patterns.put("Circuit Breaker", "Prevents cascade failures");
        patterns.put("Dead Letter Channel", "Handles poison messages");
        patterns.put("Content Enricher", "Adds data to messages");
        
        info.put("implementedPatterns", patterns);
        
        return ResponseEntity.ok(info);
    }

    /**
     * Test specific ESB route
     */
    @GetMapping("/test/{route}")
    @Operation(summary = "Test ESB route", description = "Test a specific ESB route functionality")
    public ResponseEntity<Map<String, Object>> testESBRoute(@PathVariable String route) {
        Map<String, Object> response = new HashMap<>();
        response.put("route", route);
        response.put("status", "ready");
        response.put("endpoint", "/esb/" + route);
        response.put("message", "ESB route is configured and ready to process requests");
        
        switch (route) {
            case "api-to-soap":
                response.put("usage", "Use /esb/api-to-soap/products to get all products via SOAP");
                response.put("method", "GET");
                break;
            case "aggregate":
                response.put("usage", "Use /esb/aggregate to get aggregated data from multiple services");
                response.put("method", "GET");
                break;
            case "route":
                response.put("usage", "Use /esb/route?entity=products or /esb/route?entity=customers");
                response.put("method", "GET");
                break;
            case "loadbalance":
                response.put("usage", "Use /esb/loadbalance to see load balancing in action");
                response.put("method", "GET");
                break;
            case "circuit-breaker":
                response.put("usage", "Use /esb/circuit-breaker to test circuit breaker pattern");
                response.put("method", "GET");
                break;
            default:
                response.put("error", "Unknown route: " + route);
                return ResponseEntity.badRequest().body(response);
        }
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get ESB monitoring information
     */
    @GetMapping("/monitor")
    @Operation(summary = "ESB monitoring", description = "Get ESB monitoring and metrics information")
    public ResponseEntity<Map<String, Object>> getESBMonitoring() {
        Map<String, Object> monitoring = new HashMap<>();
        monitoring.put("jmxEnabled", true);
        monitoring.put("jmxDomain", "org.apache.camel");
        monitoring.put("managementName", "camel-1");
        monitoring.put("monitoringUrl", "Available via JMX Console");
        
        Map<String, String> metrics = new HashMap<>();
        metrics.put("routesTotal", "Total number of routes");
        metrics.put("exchangesTotal", "Total exchanges processed");
        metrics.put("exchangesCompleted", "Successfully completed exchanges");
        metrics.put("exchangesFailed", "Failed exchanges");
        metrics.put("meanProcessingTime", "Average processing time");
        
        monitoring.put("availableMetrics", metrics);
        monitoring.put("note", "Use JConsole or similar JMX client to view real-time metrics");
        
        return ResponseEntity.ok(monitoring);
    }
}
