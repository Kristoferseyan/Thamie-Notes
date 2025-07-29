package com.thamienotes.notetaking.dtos.User;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDto {
    private String first_name;
    private String last_name;
    private String username;
    private String password;
    private String email;
    private String role;
}
