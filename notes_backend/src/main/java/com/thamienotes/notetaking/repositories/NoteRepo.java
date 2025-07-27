package com.thamienotes.notetaking.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.thamienotes.notetaking.models.Notes;

public interface NoteRepo extends JpaRepository<Notes, String> {
    List<Notes> findByUserUsername(String username);
}
