package com.covataskmanager;

import com.covataskmanager.dto.TaskRequest;
import com.covataskmanager.dto.TaskResponse;
import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskPriority;
import com.covataskmanager.entity.TaskStatus;
import com.covataskmanager.entity.User;
import com.covataskmanager.repository.TaskRepository;
import com.covataskmanager.service.TaskService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    private TaskService taskService;

    private User user;
    private Task task;

    @BeforeEach
    void setUp() {
        taskService = new TaskService(taskRepository);

        user = User.builder()
                .id(1L)
                .name("Alex")
                .email("alex@test.com")
                .build();

        task = Task.builder()
                .id(1L)
                .title("Test Task")
                .description("Test Description")
                .status(TaskStatus.TODO)
                .user(user)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    @Test
    void shouldGetAllUserTasks() {
        when(taskRepository.findByUserOrderByCreatedAtDesc(user))
                .thenReturn(List.of(task));

        var result = taskService.getUserTasks(user, null, null, null);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getTitle()).isEqualTo("Test Task");
        verify(taskRepository).findByUserOrderByCreatedAtDesc(user);
    }

    @Test
    void shouldFilterTasksByStatus() {
        when(taskRepository.findByUserAndStatusOrderByCreatedAtDesc(user, TaskStatus.TODO))
                .thenReturn(List.of(task));

        var result = taskService.getUserTasks(user, "TODO", null, null);

        assertThat(result).hasSize(1);
        verify(taskRepository).findByUserAndStatusOrderByCreatedAtDesc(user, TaskStatus.TODO);
    }

    @Test
    void shouldSearchTasksByTitle() {
        when(taskRepository.searchByUserAndTitle(user, "test"))
                .thenReturn(List.of(task));

        var result = taskService.getUserTasks(user, null, null, "test");

        assertThat(result).hasSize(1);
        verify(taskRepository).searchByUserAndTitle(user, "test");
    }

    @Test
    void shouldCreateTask() {
        var request = TaskRequest.builder()
                .title("New Task")
                .description("New Description")
                .status("TODO")
                .build();

        when(taskRepository.save(any(Task.class))).thenReturn(task);

        var result = taskService.createTask(user, request);

        assertThat(result.getTitle()).isEqualTo("Test Task");
        verify(taskRepository).save(any(Task.class));
    }

    @Test
    void shouldUpdateTask() {
        var request = TaskRequest.builder()
                .title("Updated")
                .description("Updated Desc")
                .status("IN_PROGRESS")
                .build();

        when(taskRepository.findById(1L)).thenReturn(Optional.of(task));
        when(taskRepository.save(any(Task.class))).thenReturn(task);

        var result = taskService.updateTask(user, 1L, request);

        assertThat(result).isNotNull();
        verify(taskRepository).save(any(Task.class));
    }

    @Test
    void shouldThrowWhenTaskNotFound() {
        when(taskRepository.findById(99L)).thenReturn(Optional.empty());

        var request = TaskRequest.builder().title("X").build();

        assertThatThrownBy(() -> taskService.updateTask(user, 99L, request))
                .hasMessageContaining("Task not found");
    }

    @Test
    void shouldThrowWhenTaskBelongsToAnotherUser() {
        var otherUser = User.builder().id(2L).email("other@test.com").build();

        when(taskRepository.findById(1L)).thenReturn(Optional.of(task));

        var request = TaskRequest.builder().title("X").build();

        assertThatThrownBy(() -> taskService.updateTask(otherUser, 1L, request))
                .hasMessageContaining("Task not found");
    }

    @Test
    void shouldDeleteTask() {
        when(taskRepository.findById(1L)).thenReturn(Optional.of(task));
        doNothing().when(taskRepository).delete(task);

        taskService.deleteTask(user, 1L);

        verify(taskRepository).delete(task);
    }
}