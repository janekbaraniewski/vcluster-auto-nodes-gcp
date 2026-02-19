resource "google_service_account" "vcluster_node" {
  project      = local.project
  account_id   = format("vcluster-node-sa-%s", local.random_id)
  display_name = format("Node service account for %s", local.vcluster_name)
  description  = format("Needed by Kubernetes nodes to obtain IMDS tokens for CCM/CSI, used by %s", local.vcluster_name)
}

###################
# CCM
###################

resource "google_project_iam_member" "ccm_roles" {
  for_each = local.ccm_enabled ? toset([
    "roles/compute.viewer",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
  ]) : toset([])

  project = local.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.vcluster_node.email}"
}

###################
# CSI
###################

resource "google_project_iam_member" "csi_roles" {
  for_each = local.csi_enabled ? toset([
    "roles/compute.viewer",
    "roles/compute.storageAdmin",
    "roles/iam.serviceAccountUser",
  ]) : toset([])

  project = local.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.vcluster_node.email}"
}
