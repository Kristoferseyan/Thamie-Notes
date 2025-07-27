package com.thamienotes.notetaking.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.thamienotes.notetaking.dtos.NoteDetailsDto;
import com.thamienotes.notetaking.services.NoteService;


@RestController
@RequestMapping("/note")
public class NoteController {
    @Autowired NoteService noteService;

    @PreAuthorize("hasRole('USER')")
    @PostMapping("/createNote")
    public ResponseEntity<String> createNewNote(@RequestBody NoteDetailsDto dto) {
        noteService.createNewNote(dto);
        return ResponseEntity.ok("Note created successfully");
    }
    
}
