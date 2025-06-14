package com.xp.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.xp.dto.AuthenticationRequest;
import com.xp.dto.AuthenticationResponse;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    public void testAuthenticate() throws Exception {
        AuthenticationRequest request = new AuthenticationRequest();
        request.setUsername("admin");
        request.setPassword("admin123");
        
        MvcResult result = mockMvc.perform(post("/api/auth/authenticate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists())
                .andReturn();
        
        String content = result.getResponse().getContentAsString();
        AuthenticationResponse response = objectMapper.readValue(content, AuthenticationResponse.class);
        
        assertNotNull(response.getToken());
    }
    
    @Test
    @WithMockUser(username = "user", roles = "USER")
    public void testGetAllProducts() throws Exception {
        mockMvc.perform(get("/api/products")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").exists())
                .andExpect(jsonPath("$[0].name").exists());
    }
    
    @Test
    @WithMockUser(username = "user", roles = "USER")
    public void testGetAllCustomers() throws Exception {
        mockMvc.perform(get("/api/customers")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").exists())
                .andExpect(jsonPath("$[0].firstName").exists())
                .andExpect(jsonPath("$[0].lastName").exists());
    }
}
