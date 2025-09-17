package com.xp.esb.config;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * ESB Configuration using Apache Camel
 * Demonstrates Enterprise Service Bus implementation
 */
@Configuration
public class ESBConfig {

    // Servlet registration moved to CamelServletConfig to avoid conflicts

    /**
     * ESB Routes configuration
     */
    @Bean
    public RouteBuilder esbRoutes() {
        return new ESBRoutes();
    }
}
