package com.thamienotes.notetaking.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.thamienotes.notetaking.dtos.Note.NoteDetailsDto;
import com.thamienotes.notetaking.dtos.Note.NoteFolderDto;
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

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/getUserNotes")
    public ResponseEntity<List<NoteDetailsDto>> getUserNotes() {
        return ResponseEntity.ok(noteService.getUserNotes());
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("/updateNote/{noteId}")
    public ResponseEntity<NoteDetailsDto> udpateNote(@PathVariable String noteId, @RequestBody NoteDetailsDto dto) {
        NoteDetailsDto updatedNote = noteService.updateNote(noteId, dto);
        return ResponseEntity.ok(updatedNote);
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("addNotesToFolder")
    public ResponseEntity<String> addNotesToFolder(@RequestBody NoteFolderDto dto) {
        noteService.addNoteToFolder(dto);
        return ResponseEntity.ok("Note added to folder");
    }
    
}
