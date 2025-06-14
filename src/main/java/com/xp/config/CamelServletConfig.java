package com.xp.config;

import org.apache.camel.component.servlet.CamelHttpTransportServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Camel Servlet Configuration for ESB
 * This configuration is required to expose Camel routes via HTTP servlet
 */
@Configuration
public class CamelServletConfig {    /**
     * Register the CamelHttpTransportServlet to handle ESB requests
     * This servlet will handle all requests to /esb/* endpoints
     */
    @Bean
    public ServletRegistrationBean<CamelHttpTransportServlet> customCamelServletRegistrationBean() {
        ServletRegistrationBean<CamelHttpTransportServlet> registration = 
            new ServletRegistrationBean<>(new CamelHttpTransportServlet(), "/esb/*");
        registration.setName("CamelServlet");
        registration.setLoadOnStartup(1);
        registration.addInitParameter("matchOnUriPrefix", "false");
        return registration;
    }
}
