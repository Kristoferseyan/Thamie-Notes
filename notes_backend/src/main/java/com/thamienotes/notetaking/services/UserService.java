package com.thamienotes.notetaking.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.dtos.UserDto;
import com.thamienotes.notetaking.mapper.UserMapper;
import com.thamienotes.notetaking.models.Users;
import com.thamienotes.notetaking.repositories.UserRepo;

@Service
public class UserService {
    @Autowired UserRepo userRepo;
    @Autowired PasswordEncoder passwordEncoder;
    public void addNewUser(UserDto dto){
        Users user = UserMapper.toEntity(dto);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        userRepo.save(user);
    }
}
