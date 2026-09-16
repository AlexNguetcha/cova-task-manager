package com.covataskmanager.repository;

import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskStatus;
import com.covataskmanager.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {

    List<Task> findByUserOrderByCreatedAtDesc(User user);

    List<Task> findByUserAndStatusOrderByCreatedAtDesc(User user, TaskStatus status);

    @Query("SELECT t FROM Task t WHERE t.user = :user AND LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY t.createdAt DESC")
    List<Task> searchByUserAndTitle(@Param("user") User user, @Param("search") String search);

    @Query("SELECT t FROM Task t WHERE t.user = :user AND t.status = :status AND LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY t.createdAt DESC")
    List<Task> searchByUserAndStatusAndTitle(@Param("user") User user, @Param("status") TaskStatus status, @Param("search") String search);
}