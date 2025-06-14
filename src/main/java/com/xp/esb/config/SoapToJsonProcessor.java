package com.xp.esb.config;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * SOAP to JSON Processor for ESB
 * Transforms SOAP XML responses to JSON format
 */
@Slf4j
public class SoapToJsonProcessor implements Processor {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void process(Exchange exchange) throws Exception {
        String soapResponse = exchange.getIn().getBody(String.class);
        log.debug("Processing SOAP response: {}", soapResponse);

        try {
            // Parse XML
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new ByteArrayInputStream(soapResponse.getBytes()));

            // Check if it's a GetAllProductsResponse
            NodeList productNodes = doc.getElementsByTagNameNS("*", "ProductSoap");
            if (productNodes.getLength() > 0) {
                List<Map<String, Object>> products = new ArrayList<>();
                
                for (int i = 0; i < productNodes.getLength(); i++) {
                    Map<String, Object> product = extractProductFromNode(productNodes.item(i));
                    products.add(product);
                }
                
                Map<String, Object> response = new HashMap<>();
                response.put("products", products);
                response.put("total", products.size());
                response.put("source", "ESB-SOAP-Bridge");
                
                String jsonResponse = objectMapper.writeValueAsString(response);
                exchange.getIn().setBody(jsonResponse);
            } 
            // Check if it's a single product response
            else {
                NodeList singleProduct = doc.getElementsByTagNameNS("*", "product");
                if (singleProduct.getLength() > 0) {
                    Map<String, Object> product = extractProductFromNode(singleProduct.item(0).getFirstChild());
                    product.put("source", "ESB-SOAP-Bridge");
                    
                    String jsonResponse = objectMapper.writeValueAsString(product);
                    exchange.getIn().setBody(jsonResponse);
                } else {
                    // Fallback for unknown response format
                    Map<String, Object> errorResponse = new HashMap<>();
                    errorResponse.put("error", "Unable to parse SOAP response");
                    errorResponse.put("originalResponse", soapResponse);
                    
                    String jsonResponse = objectMapper.writeValueAsString(errorResponse);
                    exchange.getIn().setBody(jsonResponse);
                }
            }
            
        } catch (Exception e) {
            log.error("Error processing SOAP response", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "SOAP to JSON transformation failed");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("originalResponse", soapResponse);
            
            String jsonResponse = objectMapper.writeValueAsString(errorResponse);
            exchange.getIn().setBody(jsonResponse);
        }
    }

    private Map<String, Object> extractProductFromNode(org.w3c.dom.Node productNode) {
        Map<String, Object> product = new HashMap<>();
        
        org.w3c.dom.NodeList children = productNode.getChildNodes();
        for (int j = 0; j < children.getLength(); j++) {
            org.w3c.dom.Node child = children.item(j);
            if (child.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                String nodeName = child.getLocalName();
                String nodeValue = child.getTextContent();
                
                // Convert numeric fields
                if ("id".equals(nodeName) || "stock".equals(nodeName)) {
                    try {
                        product.put(nodeName, Long.parseLong(nodeValue));
                    } catch (NumberFormatException e) {
                        product.put(nodeName, nodeValue);
                    }
                } else if ("price".equals(nodeName)) {
                    try {
                        product.put(nodeName, Double.parseDouble(nodeValue));
                    } catch (NumberFormatException e) {
                        product.put(nodeName, nodeValue);
                    }
                } else {
                    product.put(nodeName, nodeValue);
                }
            }
        }
        
        return product;
    }
}
