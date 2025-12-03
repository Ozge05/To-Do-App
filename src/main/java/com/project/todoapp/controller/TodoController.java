package com.project.todoapp.controller;

import com.project.todoapp.dto.todo.TodoRequest;
import com.project.todoapp.dto.todo.TodoResponse;
import com.project.todoapp.model.Todo;
import com.project.todoapp.service.TodoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/todos")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService service;

    @PostMapping
    public ResponseEntity<TodoResponse> create(@RequestBody TodoRequest request) {
        Todo toSave = fromRequest(request);
        Todo created = service.create(toSave);
        return ResponseEntity.created(URI.create("/api/todos/" + created.getId()))
                .body(toResponse(created));
    }

    @GetMapping
    public ResponseEntity<List<TodoResponse>> getAll() {
        List<TodoResponse> list = service.getAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TodoResponse> getById(@PathVariable Long id) {
        Todo todo = service.getById(id);
        return ResponseEntity.ok(toResponse(todo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TodoResponse> update(@PathVariable Long id, @RequestBody TodoRequest request) {
        Todo updated = service.update(id, fromRequest(request));
        return ResponseEntity.ok(toResponse(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    private Todo fromRequest(TodoRequest request) {
        Todo t = new Todo();
        t.setTitle(request.getTitle());
        t.setDescription(request.getDescription());
        t.setDone(request.isDone());
        return t;
    }

    private TodoResponse toResponse(Todo todo) {
        return new TodoResponse(
                todo.getId(),
                todo.getTitle(),
                todo.getDescription(),
                todo.isDone()
        );
    }
}
