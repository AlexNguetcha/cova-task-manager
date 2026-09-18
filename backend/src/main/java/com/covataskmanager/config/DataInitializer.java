package com.covataskmanager.config;

import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskPriority;
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
@Profile({"dev", "docker", "railway"})
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

        // ── 25 Sample Tasks (insurance-related, Francophone Africa) ──
        var tasks = taskRepository.saveAll(java.util.List.of(
                Task.builder().title("Finaliser contrat auto client Dupont").description("Vérifier les pièces justificatives, calculer la prime annuelle et éditer le contrat d'assurance auto pour M. Dupont.").status(TaskStatus.TODO).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(3)).user(user).build(),
                Task.builder().title("Relancer sinistre habitation n°2024-0891").description("Contacter l'expert pour obtenir le rapport d'évaluation et relancer l'indemnisation du sinistre habitation à Douala.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(1)).user(user).build(),
                Task.builder().title("Mettre à jour grille tarifaire santé").description("Intégrer les nouveaux barèmes 2025 pour les garanties santé individuelles et familiales en zone CEMAC.").status(TaskStatus.COMPLETED).priority(TaskPriority.MEDIUM).user(user).build(),
                Task.builder().title("Souscrire assurance vie client Martin").description("Préparer le dossier de souscription, vérifier le questionnaire médical et programmer le prélèvement en CFA.").status(TaskStatus.TODO).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(7)).user(user).build(),
                Task.builder().title("Auditer portefeuille risques professionnels").description("Analyser les 50 plus gros contrats PRO au Cameroun, identifier les écarts de cotisation et proposer des avenants.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.LOW).dueDate(java.time.LocalDate.now().plusDays(14)).user(user).build(),
                Task.builder().title("Former équipe à la conformité RGPD").description("Organiser la session de formation obligatoire sur la protection des données personnelles pour les 12 conseillers de l'agence de Yaoundé.").status(TaskStatus.COMPLETED).priority(TaskPriority.LOW).user(user).build(),
                Task.builder().title("Indemniser sinistre auto client Kamga").description("Finaliser le calcul d'indemnisation suite à l'accident du véhicule assuré par M. Kamga à Douala.").status(TaskStatus.TODO).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(2)).user(user).build(),
                Task.builder().title("Déployer nouvelle offre assurance agricole").description("Lancer la couverture climatique pour les petits exploitants agricoles en Afrique rurale avec prime à 5000 CFA/mois.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(10)).user(user).build(),
                Task.builder().title("Renouveler contrat flotte automobile").description("Contacter l'entreprise B&L Logistics pour le renouvellement annuel de l'assurance des 15 véhicules de la flotte.").status(TaskStatus.TODO).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(5)).user(user).build(),
                Task.builder().title("Traiter sinistre dégât des eaux").description("Dépêcher un expert sur le site de l'appartement endommagé au quartier Bastos et établir le rapport préliminaire.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(1)).user(user).build(),
                Task.builder().title("Mettre à jour contrats types habitation").description("Réviser les clauses des contrats d'assurance habitation pour les adapter au nouveau code OHADA.").status(TaskStatus.COMPLETED).priority(TaskPriority.MEDIUM).user(user).build(),
                Task.builder().title("Proposer assurance décès à groupe scolaire").description("Préparer une offre d'assurance décès-invalidité pour les 45 enseignants du Collège de la Madeleine à Libreville.").status(TaskStatus.TODO).priority(TaskPriority.LOW).dueDate(java.time.LocalDate.now().plusDays(20)).user(user).build(),
                Task.builder().title("Analyser sinistres récurrents région Nord").description("Étudier la fréquence des sinistres dans la région de Garoua et proposer des mesures de prévention.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(12)).user(user).build(),
                Task.builder().title("Négocier convention avec clinique").description("Rencontrer la direction de la Clinique de la Plaine pour établir une convention de tiers payant.").status(TaskStatus.TODO).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(4)).user(user).build(),
                Task.builder().title("Publier rapport annuel 2025").description("Compiler les indicateurs clés de l'exercice 2025 : sinistres, primes, nouveaux contrats et satisfaction client.").status(TaskStatus.COMPLETED).priority(TaskPriority.LOW).user(user).build(),
                Task.builder().title("Former agents à l'utilisation de l'outil CRM").description("Organiser une session de formation pour les 8 nouveaux agents sur le logiciel de gestion des sinistres.").status(TaskStatus.TODO).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(15)).user(user).build(),
                Task.builder().title("Lancer campagne sensibilisation vol").description("Distribuer des flyers et envoyer des SMS aux assurés habitation sur les bonnes pratiques anti-vol.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.LOW).dueDate(java.time.LocalDate.now().plusDays(25)).user(user).build(),
                Task.builder().title("Étudier nouveau code des assurances").description("Analyser l'impact de la nouvelle réglementation CIMA sur les produits d'assurance existants.").status(TaskStatus.TODO).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(8)).user(user).build(),
                Task.builder().title("Réviser primes transport marchandises").description("Ajuster les cotisations pour le transport de marchandises sur le corridor Douala-Ndjamena.").status(TaskStatus.COMPLETED).priority(TaskPriority.MEDIUM).user(user).build(),
                Task.builder().title("Assurer événement CAN 2027").description("Préparer la couverture assurance pour les infrastructures sportives de la Coupe d'Afrique des Nations.").status(TaskStatus.TODO).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(30)).user(user).build(),
                Task.builder().title("Recruter 5 nouveaux conseillers").description("Lancer le processus de recrutement pour les agences de Douala, Yaoundé, Libreville, Brazzaville et Abidjan.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(18)).user(user).build(),
                Task.builder().title("Développer application mobile clients").description("Superviser le développement de l'app de gestion de contrats pour les clients particuliers.").status(TaskStatus.TODO).priority(TaskPriority.LOW).dueDate(java.time.LocalDate.now().plusDays(45)).user(user).build(),
                Task.builder().title("Clôturer exercice comptable 2025").description("Finaliser la clôture des comptes avec le cabinet d'audit externe avant le 31 mars.").status(TaskStatus.COMPLETED).priority(TaskPriority.HIGH).user(user).build(),
                Task.builder().title("Mettre en place télésinistre").description("Déployer la plateforme de déclaration de sinistres en ligne avec dépôt de photos depuis le mobile.").status(TaskStatus.IN_PROGRESS).priority(TaskPriority.HIGH).dueDate(java.time.LocalDate.now().plusDays(6)).user(user).build(),
                Task.builder().title("Organiser séminaire commercial").description("Planifier le séminaire annuel des forces de vente à l'hôtel La Falaise de Limbé.").status(TaskStatus.TODO).priority(TaskPriority.MEDIUM).dueDate(java.time.LocalDate.now().plusDays(21)).user(user).build()
        ));

        log.info("Created {} insurance-related tasks for demo user.", tasks.size());
    }
}