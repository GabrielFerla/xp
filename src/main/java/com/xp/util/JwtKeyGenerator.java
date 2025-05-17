package com.xp.util;

import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.Base64;

/**
 * Utility class to generate secure JWT keys
 * Run this class main method to generate a secure key for use in application.properties
 */
public class JwtKeyGenerator {
    
    public static void main(String[] args) {
        // Generate a secure key using JJWT's utility method
        Key key = Keys.secretKeyFor(SignatureAlgorithm.HS256);
        String encodedKey = Base64.getEncoder().encodeToString(key.getEncoded());
        
        System.out.println("===========================================");
        System.out.println("Secure JWT Key (add to application.properties):");
        System.out.println("jwt.secret=" + encodedKey);
        System.out.println("===========================================");
    }
}
