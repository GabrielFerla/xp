package com.xp.soap;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.ws.client.core.WebServiceTemplate;

import com.xp.soap.model.AddProductRequest;
import com.xp.soap.model.AddProductResponse;
import com.xp.soap.model.GetAllProductsRequest;
import com.xp.soap.model.GetAllProductsResponse;
import com.xp.soap.model.GetProductRequest;
import com.xp.soap.model.GetProductResponse;
import com.xp.soap.model.ProductSoap;

import lombok.extern.slf4j.Slf4j;

/**
 * Example SOAP Client configuration (for testing purposes)
 * To run this client use the 'soap-client' profile: --spring.profiles.active=soap-client
 */
@Configuration
@Profile("soap-client")
@Slf4j
public class SoapClientExample {

    /**
     * Configure JAXB2 Marshaller for SOAP
     */
    @Bean
    public Jaxb2Marshaller marshaller() {
        Jaxb2Marshaller marshaller = new Jaxb2Marshaller();
        marshaller.setContextPath("com.xp.soap.model");
        return marshaller;
    }
    
    /**
     * Create WebServiceTemplate for SOAP requests
     */
    @Bean
    public WebServiceTemplate webServiceTemplate(Jaxb2Marshaller marshaller) {
        WebServiceTemplate template = new WebServiceTemplate();
        template.setMarshaller(marshaller);
        template.setUnmarshaller(marshaller);
        return template;
    }
    
    /**
     * Demo bean to run SOAP client examples
     */
    @Bean
    public CommandLineRunner soapClientRunner(WebServiceTemplate webServiceTemplate) {
        return args -> {
            String uri = "http://localhost:8080/ws";
            
            log.info("Running SOAP client examples...");
            
            // Get all products example
            log.info("Requesting all products...");
            GetAllProductsRequest getAllProductsRequest = new GetAllProductsRequest();
            GetAllProductsResponse getAllProductsResponse = (GetAllProductsResponse) webServiceTemplate
                    .marshalSendAndReceive(uri, getAllProductsRequest);
            
            log.info("Retrieved {} products:", getAllProductsResponse.getProducts().size());
            for (ProductSoap product : getAllProductsResponse.getProducts()) {
                log.info(" - {} (ID: {}): ${} - Stock: {}", 
                        product.getName(), product.getId(), product.getPrice(), product.getStock());
            }
            
            // Get product by ID example
            log.info("Requesting product with ID 1...");
            GetProductRequest getProductRequest = new GetProductRequest();
            getProductRequest.setId(1L);
            GetProductResponse getProductResponse = (GetProductResponse) webServiceTemplate
                    .marshalSendAndReceive(uri, getProductRequest);
            
            ProductSoap product = getProductResponse.getProduct();
            log.info("Retrieved product: {} (ID: {}): ${} - Stock: {}", 
                    product.getName(), product.getId(), product.getPrice(), product.getStock());
            
            // Add new product example
            log.info("Adding new product...");
            AddProductRequest addProductRequest = new AddProductRequest();
            addProductRequest.setName("SOAP Client Test Product");
            addProductRequest.setDescription("Product added via SOAP client");
            addProductRequest.setPrice(299.99);
            addProductRequest.setStock(25);
            
            AddProductResponse addProductResponse = (AddProductResponse) webServiceTemplate
                    .marshalSendAndReceive(uri, addProductRequest);
            
            ProductSoap newProduct = addProductResponse.getProduct();
            log.info("Created new product: {} (ID: {}): ${} - Stock: {}", 
                    newProduct.getName(), newProduct.getId(), newProduct.getPrice(), newProduct.getStock());
            
            log.info("SOAP client examples completed.");
        };
    }
}
