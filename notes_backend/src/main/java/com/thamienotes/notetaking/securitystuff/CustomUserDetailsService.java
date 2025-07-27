package com.thamienotes.notetaking.securitystuff;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.models.Users;
import com.thamienotes.notetaking.repositories.UserRepo;

@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired UserRepo userRepo;

    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException{
        Users user = userRepo.findByUsername(username)
                    .orElseThrow(() -> new UsernameNotFoundException(username));
        
        List<GrantedAuthority> authorities = List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole()));
        return new User(user.getUsername(), user.getPassword(), authorities);
    }
}
