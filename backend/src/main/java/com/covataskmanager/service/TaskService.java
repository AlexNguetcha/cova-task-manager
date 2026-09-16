package com.covataskmanager.service;

import com.covataskmanager.dto.TaskRequest;
import com.covataskmanager.dto.TaskResponse;
import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskPriority;
import com.covataskmanager.entity.TaskStatus;
import com.covataskmanager.entity.User;
import com.covataskmanager.exception.ResourceNotFoundException;
import com.covataskmanager.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;

    public List<TaskResponse> getUserTasks(User user, String status, String search, String priority) {
        List<Task> tasks;

        boolean hasStatus = status != null && !status.isBlank();
        boolean hasSearch = search != null && !search.isBlank();
        boolean hasPriority = priority != null && !priority.isBlank();

        if (hasStatus && hasSearch && hasPriority) {
            tasks = taskRepository.findByUserAndStatusAndPriorityAndTitleContaining(user,
                    TaskStatus.valueOf(status.toUpperCase()),
                    TaskPriority.valueOf(priority.toUpperCase()), search);
        } else if (hasStatus && hasPriority) {
            tasks = taskRepository.findByUserAndStatusAndPriority(user,
                    TaskStatus.valueOf(status.toUpperCase()),
                    TaskPriority.valueOf(priority.toUpperCase()));
        } else if (hasStatus) {
            tasks = taskRepository.findByUserAndStatusOrderByCreatedAtDesc(user, TaskStatus.valueOf(status.toUpperCase()));
        } else if (hasPriority) {
            tasks = taskRepository.findByUserAndPriorityOrderByCreatedAtDesc(user, TaskPriority.valueOf(priority.toUpperCase()));
        } else if (hasSearch) {
            tasks = taskRepository.searchByUserAndTitle(user, search);
        } else {
            tasks = taskRepository.findByUserOrderByCreatedAtDesc(user);
        }

        return tasks.stream().map(this::toResponse).toList();
    }

    public TaskResponse getTaskById(User user, Long id) {
        var task = findTaskForUser(user, id);
        return toResponse(task);
    }

    @Transactional
    public TaskResponse createTask(User user, TaskRequest request) {
        var task = Task.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .status(request.getStatus() != null
                        ? TaskStatus.valueOf(request.getStatus().toUpperCase())
                        : TaskStatus.TODO)
                .priority(request.getPriority() != null
                        ? TaskPriority.valueOf(request.getPriority().toUpperCase())
                        : TaskPriority.MEDIUM)
                .dueDate(request.getDueDate())
                .user(user)
                .build();

        task = taskRepository.save(task);
        return toResponse(task);
    }

    @Transactional
    public TaskResponse updateTask(User user, Long id, TaskRequest request) {
        var task = findTaskForUser(user, id);

        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            task.setStatus(TaskStatus.valueOf(request.getStatus().toUpperCase()));
        }
        if (request.getPriority() != null) {
            task.setPriority(TaskPriority.valueOf(request.getPriority().toUpperCase()));
        }
        if (request.getDueDate() != null) {
            task.setDueDate(request.getDueDate());
        }

        task = taskRepository.save(task);
        return toResponse(task);
    }

    @Transactional
    public void deleteTask(User user, Long id) {
        var task = findTaskForUser(user, id);
        taskRepository.delete(task);
    }

    private Task findTaskForUser(User user, Long id) {
        var task = taskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));

        if (!task.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Task not found with id: " + id);
        }

        return task;
    }

    private TaskResponse toResponse(Task task) {
        return TaskResponse.builder()
                .id(task.getId())
                .title(task.getTitle())
                .description(task.getDescription())
                .status(task.getStatus())
                .priority(task.getPriority())
                .dueDate(task.getDueDate())
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }
}