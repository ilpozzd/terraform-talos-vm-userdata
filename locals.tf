locals {

  cluster_etcd_configuration = {
    etcd = merge(
      lookup(var.control_plane_cluster_secrets, "etcd", {}),
      lookup(var.control_plane_cluster_configuration, "etcd", {}),
    )
  }

  control_plane_cluster_secrets       = { for k, v in var.control_plane_cluster_secrets : k => v if k != "etcd" }
  control_plane_cluster_configuration = { for k, v in var.control_plane_cluster_configuration : k => v if k != "etcd" }

  configuration = replace(
    yamlencode(
      merge(
        var.talos_base_configuration,
        {
          machine = merge(
            var.machine_secrets,
            var.machine_base_configuration,
            var.machine_extra_configuration,
            { type = var.machine_type },
            { certSANs = var.machine_cert_sans },
            {
              network = merge(
                var.machine_network,
                { hostname = var.machine_network_hostname },
                { interfaces = var.machine_network_interfaces }
              )
            }
          )
        },
        {
          cluster = merge(
            var.cluster_secrets,
            local.control_plane_cluster_secrets,
            local.cluster_etcd_configuration,
            { clusterName = var.cluster_name },
            { controlPlane = var.cluster_control_plane },
            { discovery = var.cluster_discovery },
            local.control_plane_cluster_configuration,
            { inlineManifests = var.cluster_inline_manifests },
            { extraManifests = var.cluster_extra_manifests },
            { extraManifestHeaders = var.cluster_extra_manifest_headers }
          )
        }
      )
    ),
  "/.*: null\n/", "")
}
