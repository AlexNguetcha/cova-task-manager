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
        if (userRepository.findByEmail("demo@cova.africa").isPresent()) {
            log.info("Seed data already exists, skipping initialization.");
            return;
        }

        log.info("Initializing seed data...");

        // ── Demo User ──
        var user = User.builder()
                .name("Agent Cova")
                .email("demo@cova.africa")
                .password(passwordEncoder.encode("demo1234"))
                .build();

        user = userRepository.save(user);
        log.info("Created demo user: {} <demo@cova.africa> / password: demo1234", user.getId());

        // ── Sample Tasks (insurance-related) ──
        var tasks = taskRepository.saveAll(java.util.List.of(
                Task.builder()
                        .title("Finaliser contrat auto client Dupont")
                        .description("Vérifier les pièces justificatives, calculer la prime annuelle et éditer le contrat d'assurance auto pour M. Dupont.")
                        .status(TaskStatus.TODO)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Relancer sinistre habitation n°2024-0891")
                        .description("Contacter l'expert pour obtenir le rapport d'évaluation et relancer l'indemnisation du sinistre habitation.")
                        .status(TaskStatus.IN_PROGRESS)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Mettre à jour grille tarifaire santé")
                        .description("Intégrer les nouveaux barèmes 2025 pour les garanties santé individuelles et familiales.")
                        .status(TaskStatus.COMPLETED)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Souscrire assurance vie client Martin")
                        .description("Préparer le dossier de souscription, vérifier le questionnaire médical et programmer le prélèvement.")
                        .status(TaskStatus.TODO)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Auditer portefeuille risques professionnels")
                        .description("Analyser les 50 plus gros contrats PRO, identifier les écarts de cotisation et proposer des avenants.")
                        .status(TaskStatus.IN_PROGRESS)
                        .user(user)
                        .build(),
                Task.builder()
                        .title("Former équipe à la conformité RGPD")
                        .description("Organiser la session de formation obligatoire sur la protection des données personnelles pour les 12 conseillers.")
                        .status(TaskStatus.COMPLETED)
                        .user(user)
                        .build()
        ));

        log.info("Created {} insurance-related tasks for demo user.", tasks.size());
    }
}