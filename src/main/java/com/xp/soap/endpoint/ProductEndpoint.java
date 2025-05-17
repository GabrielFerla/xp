package com.xp.soap.endpoint;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import com.xp.dto.ProductDTO;
import com.xp.factory.ProductFactory;
import com.xp.service.ProductService;
import com.xp.soap.model.AddProductRequest;
import com.xp.soap.model.AddProductResponse;
import com.xp.soap.model.GetAllProductsRequest;
import com.xp.soap.model.GetAllProductsResponse;
import com.xp.soap.model.GetProductRequest;
import com.xp.soap.model.GetProductResponse;
import com.xp.soap.model.ProductSoap;

/**
 * SOAP Web Service Endpoint for Product operations
 */
@Endpoint
public class ProductEndpoint {

    private static final String NAMESPACE_URI = "http://www.xp.com/soap/model";
    
    @Autowired
    private ProductService productService;
    
    /**
     * Get a product by ID
     * @param request The request containing the product ID
     * @return The response containing the product
     */
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "GetProductRequest")
    @ResponsePayload
    public GetProductResponse getProduct(@RequestPayload GetProductRequest request) {
        ProductDTO productDTO = productService.getProductById(request.getId());
        ProductSoap productSoap = ProductFactory.createProductSoap(productDTO);
        
        GetProductResponse response = new GetProductResponse();
        response.setProduct(productSoap);
        return response;
    }
    
    /**
     * Get all products
     * @param request The empty request
     * @return The response containing all products
     */
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "GetAllProductsRequest")
    @ResponsePayload
    public GetAllProductsResponse getAllProducts(@RequestPayload GetAllProductsRequest request) {
        List<ProductDTO> productDTOs = productService.getAllProducts();
        List<ProductSoap> productSoaps = productDTOs.stream()
                .map(ProductFactory::createProductSoap)
                .collect(Collectors.toList());
        
        GetAllProductsResponse response = new GetAllProductsResponse();
        response.setProducts(productSoaps);
        return response;
    }
    
    /**
     * Add a new product
     * @param request The request containing the new product data
     * @return The response containing the created product
     */
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "AddProductRequest")
    @ResponsePayload
    public AddProductResponse addProduct(@RequestPayload AddProductRequest request) {
        ProductDTO productDTO = new ProductDTO();
        productDTO.setName(request.getName());
        productDTO.setDescription(request.getDescription());
        productDTO.setPrice(request.getPrice());
        productDTO.setStock(request.getStock());
        
        ProductDTO createdProductDTO = productService.createProduct(productDTO);
        ProductSoap productSoap = ProductFactory.createProductSoap(createdProductDTO);
        
        AddProductResponse response = new AddProductResponse();
        response.setProduct(productSoap);
        return response;
    }
}
