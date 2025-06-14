package com.xp;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.xp.dto.ProductDTO;
import com.xp.service.ProductService;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class XpApplicationTests {

	@Autowired
	private MockMvc mockMvc;
	
	@Autowired
	private ObjectMapper objectMapper;
	
	@MockBean
	private ProductService productService;
	
	private List<ProductDTO> productDTOs;
	private ProductDTO productDTO;
	
	@BeforeEach
	void setUp() {
		productDTO = new ProductDTO(1L, "Test Product", "Test Description", 99.99, 10);
		
		productDTOs = Arrays.asList(
				productDTO,
				new ProductDTO(2L, "Another Product", "Another Description", 49.99, 20)
		);
	}

	@Test
	void contextLoads() {
	}
	
	@Test
	@WithMockUser(username = "user", roles = "USER")
	void testGetAllProducts() throws Exception {
		when(productService.getAllProducts()).thenReturn(productDTOs);
		
		mockMvc.perform(get("/api/products")
				.contentType(MediaType.APPLICATION_JSON))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$[0].id").value(1))
				.andExpect(jsonPath("$[0].name").value("Test Product"))
				.andExpect(jsonPath("$[1].id").value(2))
				.andExpect(jsonPath("$[1].name").value("Another Product"));
	}
	
	@Test
	@WithMockUser(username = "user", roles = "USER")
	void testGetProductById() throws Exception {
		when(productService.getProductById(1L)).thenReturn(productDTO);
		
		mockMvc.perform(get("/api/products/1")
				.contentType(MediaType.APPLICATION_JSON))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.id").value(1))
				.andExpect(jsonPath("$.name").value("Test Product"));
	}
	
	@Test
	@WithMockUser(username = "user", roles = "USER")
	void testCreateProduct() throws Exception {
		when(productService.createProduct(any(ProductDTO.class))).thenReturn(productDTO);
		
		mockMvc.perform(post("/api/products")
				.contentType(MediaType.APPLICATION_JSON)
				.content(objectMapper.writeValueAsString(productDTO)))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.id").value(1))
				.andExpect(jsonPath("$.name").value("Test Product"));
	}
}
