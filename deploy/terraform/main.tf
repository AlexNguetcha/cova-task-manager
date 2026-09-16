# Infrastructure as Code (Terraform) - Optionnel mais valorisé
# Pour gérer l'infrastructure GCP de manière reproductible

terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── Cloud SQL (MySQL) ──
resource "google_sql_database_instance" "mysql" {
  name             = "cova-mysql"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier              = "db-f1-micro"
    disk_type         = "PD_HDD"
    disk_size         = 10
    disk_autoresize   = true
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = false
      start_time                     = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
      require_ssl     = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = "cova_tasks"
  instance = google_sql_database_instance.mysql.name
}

resource "google_sql_user" "app_user" {
  name     = "cova_user"
  instance = google_sql_database_instance.mysql.name
  password = var.db_password
}

# ── Cloud Run Services ──
resource "google_cloud_run_service" "backend" {
  name     = "cova-backend"
  location = var.region

  template {
    spec {
      containers {
        image = "europe-west1-docker.pkg.dev/${var.project_id}/cova-task-manager/backend:latest"
        ports {
          container_port = 8080
        }
        env {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "gcp"
        }
        env {
          name  = "MYSQL_HOST"
          value = "/cloudsql/${google_sql_database_instance.mysql.connection_name}"
        }
        env {
          name  = "MYSQL_DATABASE"
          value = google_sql_database.database.name
        }
        env {
          name  = "MYSQL_USER"
          value = google_sql_user.app_user.name
        }
        env {
          name  = "MYSQL_PASSWORD"
          value = var.db_password
        }
        env {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = "0"
        "autoscaling.knative.dev/maxScale"        = "5"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.mysql.connection_name
        "run.googleapis.com/cpu-throttling"        = "false"
        "run.googleapis.com/startup-cpu-boost"     = "true"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service" "frontend" {
  name     = "cova-frontend"
  location = var.region

  template {
    spec {
      containers {
        image = "europe-west1-docker.pkg.dev/${var.project_id}/cova-task-manager/frontend:latest"
        ports {
          container_port = 80
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }
  }

  autogenerate_revision_name = true
}

# ── IAM: Allow unauthenticated access ──
resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = google_cloud_run_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}