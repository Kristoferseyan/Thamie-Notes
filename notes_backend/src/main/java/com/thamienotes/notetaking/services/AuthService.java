package com.thamienotes.notetaking.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.dtos.AuthDto;
import com.thamienotes.notetaking.dtos.LoginResponseDto;
import com.thamienotes.notetaking.models.Users;
import com.thamienotes.notetaking.repositories.UserRepo;
import com.thamienotes.notetaking.securitystuff.JwtUtil;

@Service
public class AuthService {
    @Autowired UserRepo userRepo;
    @Autowired JwtUtil jwtUtil;
    @Autowired PasswordEncoder passwordEncoder;

    public LoginResponseDto authLogin(AuthDto dto){
        Users user = userRepo.findByUsername(dto.getUsername())
                                .orElseThrow(() -> new UsernameNotFoundException("Username not found"));

        if(!passwordEncoder.matches(dto.getPassword(), user.getPassword())){
            throw new BadCredentialsException("Password incorrect");
        }
        String jwt = jwtUtil.generateToken(user);
        return new LoginResponseDto(
            user.getUsername(),
            user.getFirst_name(),
            user.getLast_name(),
            user.getEmail(),
            user.getRole(),
            jwt

        );
    }
}
