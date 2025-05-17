package com.xp.soap.model;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Add Product Request for SOAP
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "name",
    "description",
    "price",
    "stock"
})
@XmlRootElement(name = "AddProductRequest")
public class AddProductRequest {
    
    @XmlElement(required = true)
    private String name;
    
    @XmlElement(required = false)
    private String description;
    
    @XmlElement(required = true)
    private Double price;
    
    @XmlElement(required = true)
    private Integer stock;
}
