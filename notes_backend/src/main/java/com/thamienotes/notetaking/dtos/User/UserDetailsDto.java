package com.thamienotes.notetaking.dtos.User;

import java.util.List;

import com.thamienotes.notetaking.models.Notes;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDetailsDto {
    private String first_name;
    private String last_name;
    private String username;
    private String password;
    private String email;
    private String role;
    private List<Notes> notes;
}
