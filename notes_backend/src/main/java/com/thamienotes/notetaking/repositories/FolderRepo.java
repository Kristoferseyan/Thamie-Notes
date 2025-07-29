package com.thamienotes.notetaking.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.thamienotes.notetaking.models.Folder;

public interface FolderRepo extends JpaRepository<Folder, String> {
    List<Folder> findByUserUsername(String username);
}
