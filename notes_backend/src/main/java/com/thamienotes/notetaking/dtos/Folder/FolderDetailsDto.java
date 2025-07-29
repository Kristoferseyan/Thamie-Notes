package com.thamienotes.notetaking.dtos.Folder;

import java.util.List;

import com.thamienotes.notetaking.dtos.Note.NoteDetailsDto;
import com.thamienotes.notetaking.dtos.User.UserDto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FolderDetailsDto {
    private String id;
    private String title;
    private UserDto user;
    private List<NoteDetailsDto> notes;
}
