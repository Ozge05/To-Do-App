package com.project.todoapp.dto.todo;

import lombok.Data;

@Data
public class TodoRequest {
    private String title;
    private String description;
    private boolean done;
}
