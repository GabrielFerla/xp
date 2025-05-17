package com.xp.factory;

import com.xp.dto.ProductDTO;
import com.xp.model.Product;
import com.xp.soap.model.ProductSoap;

/**
 * Product Factory for creating Product objects
 * Demonstrates Factory pattern implementation
 */
public class ProductFactory {
    
    /**
     * Create a Product entity from a ProductDTO
     * @param productDTO The ProductDTO
     * @return The Product entity
     */
    public static Product createProductEntity(ProductDTO productDTO) {
        Product product = new Product();
        product.setId(productDTO.getId());
        product.setName(productDTO.getName());
        product.setDescription(productDTO.getDescription());
        product.setPrice(productDTO.getPrice());
        product.setStock(productDTO.getStock());
        return product;
    }
    
    /**
     * Create a ProductDTO from a Product entity
     * @param product The Product entity
     * @return The ProductDTO
     */
    public static ProductDTO createProductDTO(Product product) {
        ProductDTO productDTO = new ProductDTO();
        productDTO.setId(product.getId());
        productDTO.setName(product.getName());
        productDTO.setDescription(product.getDescription());
        productDTO.setPrice(product.getPrice());
        productDTO.setStock(product.getStock());
        return productDTO;
    }
    
    /**
     * Create a ProductSoap from a ProductDTO
     * @param productDTO The ProductDTO
     * @return The ProductSoap
     */
    public static ProductSoap createProductSoap(ProductDTO productDTO) {
        ProductSoap productSoap = new ProductSoap();
        productSoap.setId(productDTO.getId());
        productSoap.setName(productDTO.getName());
        productSoap.setDescription(productDTO.getDescription());
        productSoap.setPrice(productDTO.getPrice());
        productSoap.setStock(productDTO.getStock());
        return productSoap;
    }
}
