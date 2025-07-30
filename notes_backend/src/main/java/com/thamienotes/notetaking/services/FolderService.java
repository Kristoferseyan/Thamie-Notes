package com.thamienotes.notetaking.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.thamienotes.notetaking.dtos.Folder.FolderDetailsDto;
import com.thamienotes.notetaking.dtos.Folder.FolderDto;
import com.thamienotes.notetaking.mapper.FolderDetailsMapper;
import com.thamienotes.notetaking.mapper.FolderMapper;
import com.thamienotes.notetaking.models.Folder;
import com.thamienotes.notetaking.models.Users;
import com.thamienotes.notetaking.repositories.FolderRepo;
import com.thamienotes.notetaking.repositories.UserRepo;

@Service
public class FolderService {
    @Autowired FolderRepo folderRepo;
    @Autowired UserRepo userRepo;


    
    public FolderDto createFolder(FolderDetailsDto dto){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Users user = userRepo.findByUsername(auth.getName())
        .orElseThrow(() -> new UsernameNotFoundException("Username not found"));
        Folder folder = FolderDetailsMapper.toEntity(dto, user);
        Folder savedFolder = folderRepo.save(folder);
        return FolderMapper.toDto(savedFolder);
    }

    public List<FolderDetailsDto> getFolders(){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        List<Folder> folders = folderRepo.findByUserUsername(auth.getName());
        return folders.stream()
                        .map(FolderDetailsMapper::toDto)
                        .toList();

    }
}
