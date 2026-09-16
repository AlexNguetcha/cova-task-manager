package com.covataskmanager.config;

import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskStatus;
import com.covataskmanager.entity.User;
import com.covataskmanager.repository.TaskRepository;
import com.covataskmanager.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
@Profile({"dev", "docker"})
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final TaskRepository taskRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.findByEmail("demo@cova.io").isPresent()) {
            log.info("Seed data already exists, skipping initialization.");
            return;
        }

        log.info("Initializing seed data...");

        // ── Demo User ──
        var user = User.builder()
                .name("Demo User")
                .email("demo@cova.io")
                .password(passwordEncoder.encode("demo1234"))
                .build();

        user = userRepository.save(user);
        log.info("Created demo user: {} <demo@cova.io> / password: demo1234", user.getId());

        // ── Sample Tasks ──
        var tasks = taskRepository.saveAll(java.util.List.of(
                Task.builder()
                        .title("Design landing page")
                        .description("Create wireframes and high-fidelity mockups for the marketing site.")
                        .status(TaskStatus.TODO)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Set up CI/CD pipeline")
                        .description("Configure GitHub Actions for automated testing, Docker build, and Cloud Run deployment.")
                        .status(TaskStatus.IN_PROGRESS)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Write API documentation")
                        .description("Document all REST endpoints with request/response examples in Swagger/OpenAPI.")
                        .status(TaskStatus.COMPLETED)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Implement JWT refresh token")
                        .description("Add refresh token endpoint and automatic token rotation on the frontend.")
                        .status(TaskStatus.TODO)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Optimize database queries")
                        .description("Add proper indexing and analyze slow queries with Hibernate stats.")
                        .status(TaskStatus.IN_PROGRESS)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Add pagination to task list")
                        .description("Support page, size, and sort parameters on GET /api/tasks.")
                        .status(TaskStatus.COMPLETED)
                        .user(user)
                        .build()
        ));

        log.info("Created {} sample tasks for demo user.", tasks.size());
    }
}