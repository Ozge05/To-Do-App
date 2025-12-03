package com.project.todoapp.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "TODO")
public class Todo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "TITLE", nullable = false)
    private String title;

    @Column(name = "DESCRIPTION")
    private String description;

    @Column(name = "IS_DONE")
    private boolean done;
}
