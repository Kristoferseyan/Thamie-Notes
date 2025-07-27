package com.thamienotes.notetaking.config;

import org.springframework.context.annotation.Configuration;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.annotation.PostConstruct;

@Configuration
public class EnvironmentConfig {

    @PostConstruct
    public void loadEnvironmentVariables() {
        try {
            
            Dotenv dotenv = Dotenv.configure()
                    .ignoreIfMissing() 
                    .load();
            
            
            dotenv.entries().forEach(entry -> {
                
                if (System.getProperty(entry.getKey()) == null && System.getenv(entry.getKey()) == null) {
                    System.setProperty(entry.getKey(), entry.getValue());
                }
            });
            
        } catch (Exception e) {
            
            System.out.println("Warning: Could not load .env file - " + e.getMessage());
        }
    }
}
