package com.thamienotes.notetaking.models;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name="notes")
@Data
public class Notes {
    @Id
    @GeneratedValue(strategy=GenerationType.UUID)
    private String id;
    private String title;
    private String mediumtext;
    @Column(name="created_at",  updatable=false, insertable=false)
    private LocalDateTime createdAt;
    @Column(name="updated_at", updatable=false, insertable=false)
    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name="user_id", nullable=false)
    private Users user;
}
