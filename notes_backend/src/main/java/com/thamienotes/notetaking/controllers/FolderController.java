package com.thamienotes.notetaking.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.thamienotes.notetaking.dtos.Folder.FolderDetailsDto;
import com.thamienotes.notetaking.dtos.Folder.FolderDto;
import com.thamienotes.notetaking.services.FolderService;


@RestController
@RequestMapping("/folder")
public class FolderController {
    @Autowired FolderService folderService;

    @PreAuthorize("hasRole('USER')")
    @PostMapping("/createFolder")
    public ResponseEntity<String> createFolder(@RequestBody FolderDto dto) {
        folderService.createFolder(dto);
        return ResponseEntity.ok("Folder created successfully");
    }
    
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/getFolders")
    public ResponseEntity<List<FolderDetailsDto>> getFolders(){
        return ResponseEntity.ok(folderService.getFolders());
    }
}
