package com.thamienotes.notetaking.models;

import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name="user")
@Data
public class Users {
    @Id
    @GeneratedValue(strategy=GenerationType.UUID)
    private String id;
    private String first_name;
    private String last_name;
    private String username;
    private String password;
    private String email;
    private String role;

    @OneToMany(mappedBy="user", cascade=CascadeType.ALL, orphanRemoval=true)
    private List<Notes> notes;


}
