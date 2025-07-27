package com.thamienotes.notetaking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class NotetakingApplication {

	public static void main(String[] args) {
		io.github.cdimascio.dotenv.Dotenv dotenv = io.github.cdimascio.dotenv.Dotenv.configure().load();
		System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));
		System.setProperty("DB_URL", dotenv.get("DB_URL"));
		System.setProperty("DB_USERNAME", dotenv.get("DB_USERNAME"));
		System.setProperty("DB_PASSWORD", dotenv.get("DB_PASSWORD"));

		SpringApplication.run(NotetakingApplication.class, args);
	}
}