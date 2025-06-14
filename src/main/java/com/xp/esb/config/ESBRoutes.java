package com.xp.esb.config;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.dataformat.JsonLibrary;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

/**
 * ESB Routes - Enterprise Service Bus routing configuration
 * Demonstrates message routing, transformation, and integration patterns
 */
@Component
@Slf4j
public class ESBRoutes extends RouteBuilder {

    // Constants for endpoint URLs to avoid duplication
    private static final String PRODUCTS_API_ENDPOINT = "http://localhost:8080/api/products?bridgeEndpoint=true";
    private static final String CUSTOMERS_API_ENDPOINT = "http://localhost:8080/api/customers?bridgeEndpoint=true";
    private static final String SOAP_WS_ENDPOINT = "http://localhost:8080/ws?bridgeEndpoint=true";
    private static final String DIRECT_GET_ALL_PRODUCTS_SOAP = "direct:getAllProductsSOAP";
    private static final String DIRECT_TRANSFORM_SOAP_TO_JSON = "direct:transformSoapToJson";
    private static final String APPLICATION_JSON = "application/json";
    private static final String CAMEL_HTTP_PATH = "CamelHttpPath";

    @Override
    public void configure() throws Exception {
        
        // Enable JMX monitoring for ESB
        getContext().setUseMDCLogging(true);
        
        // Global error handler
        errorHandler(defaultErrorHandler()
            .maximumRedeliveries(3)
            .redeliveryDelay(2000)
            .onExceptionOccurred(new Processor() {
                @Override
                public void process(Exchange exchange) throws Exception {
                    Exception cause = exchange.getProperty(Exchange.EXCEPTION_CAUGHT, Exception.class);
                    log.error("ESB Route Error: {}", cause.getMessage(), cause);
                }
            }));

        // Route 1: REST to SOAP Bridge
        // Transforms REST API calls to SOAP Web Service calls
        from("servlet:///api-to-soap?servletName=CamelServlet")
            .routeId("rest-to-soap-bridge")
            .log("ESB: Processing REST to SOAP transformation for ${header." + CAMEL_HTTP_PATH + "}")
            .choice()
                .when(header(CAMEL_HTTP_PATH).isEqualTo("/products"))
                    .to(DIRECT_GET_ALL_PRODUCTS_SOAP)
                .when(header(CAMEL_HTTP_PATH).regex("/products/\\d+"))
                    .to("direct:getProductByIdSOAP")
                .otherwise()
                    .setBody(constant("{\"error\":\"Endpoint not found\"}"))
                    .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(404))
            .end();

        // Route 2: Get All Products SOAP Call
        from(DIRECT_GET_ALL_PRODUCTS_SOAP)
            .routeId("get-all-products-soap")
            .setBody(constant("<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                           "xmlns:tns=\"http://www.xp.com/soap/model\">" +
                           "<soap:Header/>" +
                           "<soap:Body>" +
                           "<tns:GetAllProductsRequest/>" +
                           "</soap:Body>" +
                           "</soap:Envelope>"))
            .setHeader(Exchange.CONTENT_TYPE, constant("text/xml; charset=utf-8"))
            .setHeader("SOAPAction", constant(""))
            .to(SOAP_WS_ENDPOINT)
            .to(DIRECT_TRANSFORM_SOAP_TO_JSON);

        // Route 3: Get Product by ID SOAP Call
        from("direct:getProductByIdSOAP")
            .routeId("get-product-by-id-soap")
            .process(new Processor() {
                @Override
                public void process(Exchange exchange) throws Exception {
                    String path = exchange.getIn().getHeader(CAMEL_HTTP_PATH, String.class);
                    String productId = path.substring(path.lastIndexOf("/") + 1);
                    
                    String soapBody = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                                    "xmlns:tns=\"http://www.xp.com/soap/model\">" +
                                    "<soap:Header/>" +
                                    "<soap:Body>" +
                                    "<tns:GetProductRequest>" +
                                    "<tns:id>" + productId + "</tns:id>" +
                                    "</tns:GetProductRequest>" +
                                    "</soap:Body>" +
                                    "</soap:Envelope>";
                    
                    exchange.getIn().setBody(soapBody);
                }
            })
            .setHeader(Exchange.CONTENT_TYPE, constant("text/xml; charset=utf-8"))
            .setHeader("SOAPAction", constant(""))
            .to(SOAP_WS_ENDPOINT)
            .to(DIRECT_TRANSFORM_SOAP_TO_JSON);

        // Route 4: SOAP to JSON Transformation
        from(DIRECT_TRANSFORM_SOAP_TO_JSON)
            .routeId("soap-to-json-transformer")
            .log("ESB: Transforming SOAP response to JSON")
            .process(new SoapToJsonProcessor())
            .setHeader(Exchange.CONTENT_TYPE, constant(APPLICATION_JSON));

        // Route 5: Message Aggregation Route
        from("servlet:///aggregate?servletName=CamelServlet")
            .routeId("message-aggregator")
            .log("ESB: Starting message aggregation")
            .multicast()
                .to(DIRECT_GET_ALL_PRODUCTS_SOAP)
                .to(CUSTOMERS_API_ENDPOINT)
            .end()
            .aggregate(constant(true))
                .aggregationStrategy(new MessageAggregationStrategy())
                .completionSize(2)
                .completionTimeout(5000)
                .process(new AggregationProcessor())
            .setHeader(Exchange.CONTENT_TYPE, constant(APPLICATION_JSON));

        // Route 6: Message Routing Based on Content
        from("servlet:///route?servletName=CamelServlet")
            .routeId("content-based-router")
            .log("ESB: Content-based routing for ${header.entity}")
            .choice()
                .when(header("entity").isEqualTo("products"))
                    .to(PRODUCTS_API_ENDPOINT)
                .when(header("entity").isEqualTo("customers"))
                    .to(CUSTOMERS_API_ENDPOINT)
                .otherwise()
                    .setBody(constant("{\"error\":\"Unknown entity type\"}"))
                    .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(400))
            .end();

        // Route 7: Load Balancer Route
        from("servlet:///loadbalance?servletName=CamelServlet")
            .routeId("load-balancer")
            .log("ESB: Load balancing request")
            .loadBalance().roundRobin()
                .to(PRODUCTS_API_ENDPOINT)
                .to(DIRECT_GET_ALL_PRODUCTS_SOAP)
            .end();

        // Route 8: Circuit Breaker Pattern
        from("servlet:///circuit-breaker?servletName=CamelServlet")
            .routeId("circuit-breaker")
            .log("ESB: Circuit breaker pattern")
            .circuitBreaker()
                .to(PRODUCTS_API_ENDPOINT)
            .onFallback()
                .setBody(constant("{\"error\":\"Service temporarily unavailable\", \"fallback\": true}"))
                .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(503))
            .end();

        // Route 9: Message Enrichment
        from("servlet:///enrich?servletName=CamelServlet")
            .routeId("message-enricher")
            .log("ESB: Message enrichment")
            .enrich(PRODUCTS_API_ENDPOINT, new MessageEnrichmentAggregationStrategy())
            .setHeader(Exchange.CONTENT_TYPE, constant(APPLICATION_JSON));

        // Route 10: Dead Letter Channel
        from("servlet:///deadletter?servletName=CamelServlet")
            .routeId("dead-letter-channel")
            .errorHandler(deadLetterChannel("direct:deadLetterQueue")
                .maximumRedeliveries(2)
                .redeliveryDelay(1000))
            .log("ESB: Processing with dead letter channel")
            .to("http://localhost:8080/api/invalid-endpoint?bridgeEndpoint=true");

        // Dead Letter Queue
        from("direct:deadLetterQueue")
            .routeId("dead-letter-queue")
            .log("ESB: Message sent to Dead Letter Queue: ${body}")
            .setBody(constant("{\"error\":\"Message processing failed\", \"status\":\"dead_letter_queue\"}"))
            .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(500));
    }
}
