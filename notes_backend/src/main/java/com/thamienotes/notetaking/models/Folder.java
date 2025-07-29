package com.thamienotes.notetaking.models;

import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name="folder")
@Data
public class Folder {
    @Id
    @GeneratedValue(strategy=GenerationType.UUID)
    private String id;
    private String title;

    @OneToMany(mappedBy="folder", cascade=CascadeType.ALL, orphanRemoval=true)
    private List<Notes> notes;

    @ManyToOne
    @JoinColumn(name="user_id", nullable=false)
    private Users user;

}
