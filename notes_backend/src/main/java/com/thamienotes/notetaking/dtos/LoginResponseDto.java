package com.thamienotes.notetaking.dtos;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginResponseDto {
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String token;
    private String role;

    public LoginResponseDto(String email, String firstName, String lastName, String role, String token, String username) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.role = role;
        this.token = token;
        this.username = username;
    }


}
