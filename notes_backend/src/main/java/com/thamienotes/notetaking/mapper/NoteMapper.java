package com.thamienotes.notetaking.mapper;

import java.util.List;
import java.util.stream.Collectors;

import com.thamienotes.notetaking.dtos.Note.NoteDetailsDto;
import com.thamienotes.notetaking.dtos.Note.NoteFolderDto;
import com.thamienotes.notetaking.models.Folder;
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

    public static List<Notes> noteToFolderToEntity(NoteFolderDto dto, Users user){
        Notes note = new Notes();
        Folder folder = new Folder();
        folder.setId(dto.getFolderId());
        return dto.getNoteIds()
                    .stream()
                    .map(noteId -> {
                        note.setUser(user);
                        note.setId(noteId);
                        note.setFolder(folder);
                        return note;
                    }).collect(Collectors.toList());
    }

    public static NoteFolderDto noteToFolderToDto(List<Notes> notes){
        NoteFolderDto dto = new NoteFolderDto();
        dto.setNoteIds(notes.stream().map(Notes::getId).collect(Collectors.toList()));
        dto.setFolderId(notes.get(0).getFolder().getId());
        return dto;
    }
}
