package com.thamienotes.notetaking.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.dtos.Note.NoteDetailsDto;
import com.thamienotes.notetaking.dtos.Note.NoteFolderDto;
import com.thamienotes.notetaking.mapper.NoteMapper;
import com.thamienotes.notetaking.models.Folder;
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
        Users user = userRepo.findByUsername(auth.getName())
                                .orElseThrow(() -> new UsernameNotFoundException("Username not found"));
        Notes note = NoteMapper.toEntity(dto, user);
        Notes savedNote = noteRepo.save(note);
        return NoteMapper.toDto(savedNote);
    }

public void addNoteToFolder(NoteFolderDto dto) {
    List<Notes> notes = noteRepo.findAllById(dto.getNoteIds());

    Folder folder = new Folder();
    folder.setId(dto.getFolderId());

    for (Notes note : notes) {
        note.setFolder(folder);
    }

    noteRepo.saveAll(notes);
}

    public List<NoteDetailsDto> getUserNotes(){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        List<Notes> notes = noteRepo.findByUserUsername(auth.getName());
        return notes.stream().map(NoteMapper::toDto).collect(Collectors.toList());
    }

    public NoteDetailsDto updateNote(String noteId, NoteDetailsDto dto){
        Notes note = noteRepo.findById(noteId)
                    .orElseThrow(() -> new IndexOutOfBoundsException("Id can't be found LMAO"));
        
        note.setTitle(dto.getTitle());
        note.setContent(dto.getContent());
        Notes updateNotes = noteRepo.save(note);
        return NoteMapper.toDto(updateNotes);
    }
}
