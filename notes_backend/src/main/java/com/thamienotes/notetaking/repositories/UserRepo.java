package com.thamienotes.notetaking.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.thamienotes.notetaking.models.Users;


public interface  UserRepo extends JpaRepository<Users, String> {
    Optional<Users> findByUsername(String username);
}
