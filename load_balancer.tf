/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# [START cloudloadbalancing_ext_http_cloudrun]
module "lb-http" {
  
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = var.lb_name
  project = var.project_id

  backends = {
    default = {
      description = null
      groups = [
        for network in google_compute_region_network_endpoint_group.serverless-neg: {
        group = network.id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}


resource "google_compute_region_network_endpoint_group" "serverless-neg" {

 for_each = local.regions
  
  provider              = google-beta
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = each.value
  
  cloud_run {
    service = google_cloud_run_service.hello[each.key].name
  }
}

# [END cloudloadbalancing_ext_http_cloudrun]
