package com.xp.service;

import java.util.List;

import com.xp.dto.ProductDTO;
import com.xp.model.Product;

/**
 * Service interface for Product operations
 */
public interface ProductService {
    
    /**
     * Get all products
     * @return List of all products
     */
    List<ProductDTO> getAllProducts();
    
    /**
     * Get a product by its ID
     * @param id The product ID
     * @return The product if found
     */
    ProductDTO getProductById(Long id);
    
    /**
     * Create a new product
     * @param productDTO The product data
     * @return The created product
     */
    ProductDTO createProduct(ProductDTO productDTO);
    
    /**
     * Update an existing product
     * @param id The product ID
     * @param productDTO The updated product data
     * @return The updated product
     */
    ProductDTO updateProduct(Long id, ProductDTO productDTO);
    
    /**
     * Delete a product
     * @param id The product ID
     */
    void deleteProduct(Long id);
}
