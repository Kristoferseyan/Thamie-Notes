package com.thamienotes.notetaking.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.thamienotes.notetaking.models.Notes;

public interface NoteRepo extends JpaRepository<Notes, String> {
    
}
