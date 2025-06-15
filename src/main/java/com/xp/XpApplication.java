package com.xp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class XpApplication {

	public static void main(String[] args) {
		SpringApplication.run(XpApplication.class, args);
	}

}
