package com.thamienotes.notetaking.mapper;

import com.thamienotes.notetaking.dtos.UserDto;
import com.thamienotes.notetaking.models.Users;

public class UserMapper {
    public static Users toEntity(UserDto dto){
        Users user = new Users();
        user.setFirst_name(dto.getFirst_name());
        user.setLast_name(dto.getLast_name());
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setRole(dto.getRole());
        return user;
    }
}
