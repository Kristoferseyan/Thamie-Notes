package com.thamienotes.notetaking.dtos;

import java.util.List;

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
