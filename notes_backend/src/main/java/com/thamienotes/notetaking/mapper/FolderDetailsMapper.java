package com.thamienotes.notetaking.mapper;

import java.util.List;
import java.util.stream.Collectors;

import com.thamienotes.notetaking.dtos.FolderDetailsDto;
import com.thamienotes.notetaking.models.Folder;
import com.thamienotes.notetaking.models.Notes;
import com.thamienotes.notetaking.models.Users;

public class FolderDetailsMapper {
    public static Folder toEntity(FolderDetailsDto dto, Users user){
        Folder folder = new Folder();
        folder.setId(dto.getId());
        folder.setTitle(dto.getTitle());
        folder.setUser(user);
        List<Notes> notes = dto.getNotes()
                                .stream()
                                .map(noteDto -> NoteMapper.toEntity(noteDto, user))
                                .collect(Collectors.toList());
        folder.setNotes(notes);
        return folder;
    }

    public static FolderDetailsDto toDto(Folder folder){
        FolderDetailsDto dto = new FolderDetailsDto();
        dto.setId(folder.getId());
        dto.setTitle(folder.getTitle());
        dto.setUser(UserMapper.toDto(folder.getUser()));
        dto.setNotes(folder.getNotes()
                            .stream()
                            .map(noteDto -> NoteMapper.toDto(noteDto))
                            .collect(Collectors.toList()));
        return dto;
    }
}
