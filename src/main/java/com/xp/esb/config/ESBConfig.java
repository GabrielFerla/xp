package com.xp.esb.config;

import org.apache.camel.CamelContext;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.servlet.CamelHttpTransportServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * ESB Configuration using Apache Camel
 * Demonstrates Enterprise Service Bus implementation
 */
@Configuration
public class ESBConfig {

    /**
     * Register Camel servlet for ESB endpoints
     */
    @Bean
    public ServletRegistrationBean<CamelHttpTransportServlet> servletRegistrationBean() {
        ServletRegistrationBean<CamelHttpTransportServlet> registration = 
            new ServletRegistrationBean<>(new CamelHttpTransportServlet(), "/esb/*");
        registration.setName("CamelServlet");
        return registration;
    }

    /**
     * ESB Routes configuration
     */
    @Bean
    public RouteBuilder esbRoutes() {
        return new ESBRoutes();
    }
}
