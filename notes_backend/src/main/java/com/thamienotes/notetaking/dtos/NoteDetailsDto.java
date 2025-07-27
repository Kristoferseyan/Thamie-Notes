package com.thamienotes.notetaking.dtos;

import java.time.LocalDateTime;

import com.thamienotes.notetaking.models.Users;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NoteDetailsDto {
    private String title;
    private String content;
    private Users user;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
