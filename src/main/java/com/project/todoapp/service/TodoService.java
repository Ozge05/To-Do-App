package com.project.todoapp.service;

import com.project.todoapp.model.Todo;

import java.util.List;

public interface TodoService {

    Todo create(Todo todo);
    List<Todo> getAll();
    Todo getById(Long id);
    Todo update(Long id, Todo todo);
    void delete(Long id);
}
