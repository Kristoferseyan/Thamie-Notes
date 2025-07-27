package com.thamienotes.notetaking.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.thamienotes.notetaking.dtos.UserDto;
import com.thamienotes.notetaking.services.UserService;


@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired UserService userService;

    @PostMapping("/addUser")
    public ResponseEntity<String> addNewUser(@RequestBody UserDto dto) {
        userService.addNewUser(dto);
        return ResponseEntity.ok("User added successfully");
    }
    
}
