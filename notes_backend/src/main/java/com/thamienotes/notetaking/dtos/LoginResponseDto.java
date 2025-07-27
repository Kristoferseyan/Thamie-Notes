package com.thamienotes.notetaking.dtos;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginResponseDto {
    private String username;
    private String email;
    private String token;
    private String role;

    public LoginResponseDto(String username,String email, String role, String token) {
        this.username = username;
        this.email = email;
        this.role = role;
        this.token = token;
    }
}
