package com.thamienotes.notetaking.mapper;

import com.thamienotes.notetaking.dtos.Note.NoteDetailsDto;
import com.thamienotes.notetaking.models.Notes;
import com.thamienotes.notetaking.models.Users;

public class NoteMapper {
    public static Notes toEntity(NoteDetailsDto dto, Users user){
        Notes note = new Notes();
        note.setTitle(dto.getTitle());
        note.setContent(dto.getContent());
        note.setUser(user);
        return note;
    }

    public static NoteDetailsDto toDto(Notes notes){
        NoteDetailsDto dto = new NoteDetailsDto();
        dto.setId(notes.getId());
        dto.setTitle(notes.getTitle());
        dto.setContent(notes.getContent());
        dto.setCreatedAt(notes.getCreatedAt());
        dto.setUpdatedAt(notes.getUpdatedAt());
        return dto;
    }
}
