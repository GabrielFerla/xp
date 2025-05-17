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
 * SOAP Product model
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "id",
    "name",
    "description",
    "price",
    "stock"
})
@XmlRootElement(name = "ProductSoap")
public class ProductSoap {
    
    @XmlElement(required = true)
    private Long id;
    
    @XmlElement(required = true)
    private String name;
    
    @XmlElement(required = false)
    private String description;
    
    @XmlElement(required = true)
    private Double price;
    
    @XmlElement(required = true)
    private Integer stock;
}
