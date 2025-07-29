package com.thamienotes.notetaking.mapper;

import com.thamienotes.notetaking.dtos.User.UserDto;
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

    public static UserDto toDto(Users user){
        UserDto dto = new UserDto();
        dto.setFirst_name(user.getFirst_name());
        dto.setLast_name(user.getLast_name());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        return dto;
    }
}
