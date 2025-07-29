package com.thamienotes.notetaking.dtos.Folder;

import com.thamienotes.notetaking.models.Users;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FolderDto {
    private String title;
    private Users user;
}
