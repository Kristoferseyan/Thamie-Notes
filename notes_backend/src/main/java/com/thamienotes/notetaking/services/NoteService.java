package com.thamienotes.notetaking.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.dtos.NoteDetailsDto;
import com.thamienotes.notetaking.mapper.NoteMapper;
import com.thamienotes.notetaking.models.Notes;
import com.thamienotes.notetaking.models.Users;
import com.thamienotes.notetaking.repositories.NoteRepo;
import com.thamienotes.notetaking.repositories.UserRepo;

@Service
public class NoteService {
    @Autowired UserRepo userRepo;
    @Autowired NoteRepo noteRepo;

    public NoteDetailsDto createNewNote(NoteDetailsDto dto){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        Users user = userRepo.findByUsername(username)
                                .orElseThrow(() -> new UsernameNotFoundException("Username not found"));
        Notes note = NoteMapper.toEntity(dto, user);
        Notes savedNote = noteRepo.save(note);
        return NoteMapper.toDto(savedNote);
    }
}
