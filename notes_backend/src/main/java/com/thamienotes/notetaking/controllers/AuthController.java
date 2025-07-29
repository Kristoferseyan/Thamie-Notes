package com.thamienotes.notetaking.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.thamienotes.notetaking.dtos.Auth.AuthDto;
import com.thamienotes.notetaking.dtos.Auth.LoginResponseDto;
import com.thamienotes.notetaking.services.AuthService;

import jakarta.validation.Valid;


@RestController
@RequestMapping("/auth")
public class AuthController {
    @Autowired AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> authLogin(@Valid @RequestBody AuthDto dto) {
        LoginResponseDto loginResponseDto = authService.authLogin(dto);
        
        return ResponseEntity.ok(loginResponseDto);
    }
    
}
