package com.thamienotes.notetaking.dtos.Note;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NoteFolderDto {
    private List<String> noteIds;
    private String folderId;
}
