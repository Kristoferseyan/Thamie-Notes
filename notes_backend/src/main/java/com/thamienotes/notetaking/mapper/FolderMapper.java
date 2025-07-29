package com.thamienotes.notetaking.mapper;

import com.thamienotes.notetaking.dtos.FolderDto;
import com.thamienotes.notetaking.models.Folder;
import com.thamienotes.notetaking.models.Users;

public class FolderMapper {
    public static Folder toEntity(FolderDto dto, Users user){
        Folder folder = new Folder();
        folder.setTitle(dto.getTitle());
        folder.setUser(user);
        return folder;
    }

    public static FolderDto toDto(Folder folder){
        FolderDto dto = new FolderDto();
        dto.setTitle(folder.getTitle());
        dto.setUser(folder.getUser());
        return dto;
    }
}
