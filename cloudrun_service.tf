locals {
   regions = { 
    region-1 = "us-central1", 
    region-2 = "us-east1", 
    region-3 = "us-west1" }
}

resource "google_cloud_run_service" "hello" {

  for_each = local.regions

  name     = "hello-tf"
  location = each.value
  project  = var.project_id

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
  metadata {
    annotations = {
      # For valid annotation values and descriptions, see
      # https://cloud.google.com/sdk/gcloud/reference/run/deploy#--ingress
      "run.googleapis.com/ingress" = "all"
    }
  }
}


resource "google_cloud_run_service_iam_member" "public-access" {

  for_each = google_cloud_run_service.hello

  location = each.value.location
  project  = each.value.project
  service  = each.value.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
