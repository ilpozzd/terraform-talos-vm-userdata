# Talos OS VM Userdata Terraform Module

This module is used to describe the configuration of [Talos OS v1.0.x](https://www.talos.dev/v1.0/) with Terraform variables and convert them to a Base64 encoded string that can be used for bootstarap Kubernetes nodes on any `Virtualization platform` that supports VM initialization via user-data.

## Usage

See [examples](#examples).

## Examples

* [Talos vSphere VM Module](https://github.com/ilpozzd/terraform-talos-vsphere-vm)

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.1.9, < 2.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| talos_base_configuration | Talos OS top-level configuration. | [`object`](#talos-base-configuration-input) | [`object`](#talos-base-configuration-input) | No |
| machine_secrets | Secret data that is used to create trust relationships between virtual machines. | [`object`](#machine-secrets-input) | `-` | Yes |
| machine_base_configuration | Basic configuration of the virtual machine. | [`object`](#machine-base-configuration-input) | `-` | Yes |
| machine_extra_configuration | Extended configuration of the virtual machine. | [`object`](#machine-extra-configuration-input) | `{}` | No |
| <a name="machine-type-cell"></a> machine_type | The role of the virtual machine in the Kubernetes cluster (`controlplane` or `worker`). | `string` | `-` | Yes |
| machine_cert_sans | List of alternative names of the virtual machine. | `list(string)` | `[]` | No |
| machine_network | General network configuration of the virtual machine. | [`object`](#machine-network-input) | `{}` | No |
| <a name="machine-network-hostname-cell"></a> machine_network_hostname | A network hostname of the virtual machine (if not set will be generated automatically). | `string` | `[]` | No |
| <a name="machine-network-interfaces-cell"></a> machine_network_interfaces | A list of network interfaces of the virtual machines (if not set DHCP will be used). | [`list`](#machine-network-interfaces-input) | `[]` | No |
| cluster_secrets | Secret data that is used to establish trust relationships between Kubernetes cluster nodes. | [`object`](#cluster-secrets-input) | `-` | Yes |
| control_plane_cluster_secrets | Secret data required to establish trust relationships between components used by Control Plane nodes in the Kubernetes cluster. | [`object`](#control-plane-cluster-secrets-input) | `{}` | [Yes/No](#control-plane-cluster-secrets-input) |
| cluster_name | The name of the cluster. | `string` | `-` | Yes |
| cluster_control_plane | Data to define the API endpoint address for joining a node to the Kubernetes cluster. | [`object`](#cluster-control-plane-input) | `-` | Yes |
| cluster_discovery | Data that sets up the discovery of nodes in the Kubernetes cluster. | [`object`](#cluster-discovery-input) | [`object`](#cluster-discovery-input) | No |
| control_plane_cluster_configuration | Data that configure the components of the Control Plane nodes in the Kubernetes cluster. | [`object`](#control-plane-cluster-configuration-input) | `{}` | No |
| cluster_inline_manifests | A list of Kuberenetes manifests whose content is represented as a string. These will get automatically deployed as part of the bootstrap. | [`list`](#cluster-inline-manifests-input) | `[]` | No |
| cluster_extra_manifests | A list of `URLs` that point to additional manifests. These will get automatically deployed as part of the bootstrap. | `list(string)` | `[]` | No |
| cluster_extra_manifest_headers |A map of key value pairs that will be added while fetching the 'cluster_extra_manifests'. | `map(string)` | `{}` | No |

### Talos Base Configuration Input

```hcl
object({
  version = string
  persist = bool
})
```

Default:

```hcl
{
  version = "v1alpha1"
  persist = false
}
```

See [Config](https://www.talos.dev/v1.0/reference/configuration/#config) section in Talos Configuration Reference for detail description.

### Machine Secrets Input

```hcl
object({
  token = string
  ca = object({
    crt = string
    key = string
  })
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

### Machine Base Configuration 

```hcl
object({
  install = object({
    disk            = string
    extraKernelArgs = optional(list(string))
    image           = string
    bootloader      = bool
    wipe            = bool
    diskSelector = optional(object({
      size    = string
      model   = string
      busPath = string
    }))
    extensions = optional(list(string))
  })
  kubelet = optional(object({
    image      = string
    extraArgs  = optional(map(string))
    clusterDNS = optional(list(string))
    extraMounts = optional(list(object({
      destination = string
      type        = string
      source      = string
      options     = list(string)
    })))
    extraConfig = optional(map(string))
    nodeIP = optional(object({
      validSubnets = list(string)
    }))
  }))
  time = optional(object({
    disabled    = optional(bool)
    servers     = optional(list(string))
    bootTimeout = optional(string)
  }))
  features = optional(object({
    rbac = optional(bool)
  }))
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

### Machine Extra Configuration Input

```hcl
object({
	controlPlane = optional(object({
		controllerManager = optional(object({
			disabled = bool
		}))
		scheduler = optional(object({
			disabled = bool
		}))
	}))
	pods = optional(list(map(any)))
	disks = optional(list(object({
		device = string
		partitions = list(object({
			mountpoint = string
			size       = string
		}))
	})))
	files = optional(list(object({
		content     = string
		permissions = string
		path        = string
		op          = string
	})))
	env = optional(object({
		GRPC_GO_LOG_VERBOSITY_LEVEL = optional(string)
		GRPC_GO_LOG_SEVERITY_LEVEL  = optional(string)
		http_proxy                  = optional(string)
		https_proxy                 = optional(string)
		no_proxy                    = optional(bool)
	}))
	sysctl = optional(map(string))
	sysfs  = optional(map(string))
	registries = optional(object({
		mirrors = optional(map(object({
			endpoints = list(string)
		})))
		config = optional(map(object({
			tls = object({
				insecureSkipVerify = bool
				clientIdentity = optional(object({
					crt = string
					key = string
				}))
				ca = optional(string)
			})
			auth = optional(object({
				username      = optional(string)
				password      = optional(string)
				auth          = optional(string)
				identityToken = optional(string)
			}))
		})))
	}))
	systemDiskEncryption = optional(map(object({
		provider = string
		keys = optional(list(object({
			static = optional(object({
				passphrase = string
			}))
			nodeID = optional(map(string))
			slot   = optional(number)
		})))
		cipher    = optional(string)
		keySize   = optional(number)
		blockSize = optional(number)
		options   = optional(list(string))
	})))
	udev = optional(object({
		rules = list(string)
	}))
	logging = optional(object({
		destinations = list(object({
			endpoint = string
			format   = string
		}))
	}))
	kernel = optional(object({
		modules = list(object({
			name = string
		}))
	}))
})
```

See [MachineConfig](https://www.talos.dev/v1.0/reference/configuration/#machineconfig) section in Talos Configuration Reference for detail description.

### Machine Network Input

```hcl
object({
  nameservers = optional(list(string))
  extraHostEntries = optional(list(object({
    ip      = string
    aliases = list(string)
  })))
  kubespan = optional(object({
    enabled = bool
  }))
})
```
See [NetworkConfig](https://www.talos.dev/v1.0/reference/configuration/#networkconfig) section in Talos Configuration Reference for detail description. 

[Hostname](#machine-network-hostname-cell) and [interfaces](#machine-network-interfaces-cell) parameters are described in separate inputs.

### Machine Network Interfaces Input

```hcl
list(list(object({
  interface = optional(string)
  addresses = optional(list(string))
  routes = optional(list(object({
    network = string
    gateway = optional(string)
    source  = optional(string)
    metric  = optional(number)
  })))
  vlans = optional(list(object({
    addresses = list(string)
    routes = optional(list(object({
      network = string
      gateway = optional(string)
      source  = optional(string)
      metric  = optional(number)
    })))
    dhcp   = optional(bool)
    vlanId = number
    mtu    = number
    vip = optional(object({
      ip = string
      equinixMetal = optional(object({
        apiToken = string
      }))
      hcloud = optional(object({
        apiToken = string
      }))
    }))
  })))
  mtu = optional(number)
  bond = optional(object({
    interfaces = list(string)
    mode       = string
    lacpRate   = string
  }))
  dhcp   = optional(bool)
  ignore = optional(bool)
  dummy  = optional(bool)
  dhcpOptions = optional(object({
    routeMetric = number
    ipv4        = optional(bool)
    ipv6        = optional(bool)
  }))
  wireguard = optional(object({
    privateKey   = string
    listenPort   = number
    firewallMark = number
    peers = list(object({
      publicKey                   = string
      endpoint                    = string
      persistentKeepaliveInterval = optional(string)
      allowedIPs                  = list(string)
    }))
  }))
  vip = optional(object({
    ip = string
    equinixMetal = optional(object({
      apiToken = string
    }))
    hcloud = optional(object({
      apiToken = string
    }))
  }))
})))
```

See [Device](https://www.talos.dev/v1.0/reference/configuration/#device) section in Talos Configuration Reference for detail description. 

### Cluster Secrets Input

```hcl
object({
  id     = string
  secret = string
  token  = string
  ca = object({
    crt = string
    key = string
  })
})
```
See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description. 

### Control Plane Cluster Secrets Input

```hcl
object({
  aescbcEncryptionSecret = optional(string)
  aggregatorCA = optional(object({
    crt = optional(string)
    key = optional(string)
  }))
  serviceAccount = optional(object({
    key = optional(string)
  }))
  etcd = optional(object({
    ca = object({
      crt = optional(string)
      key = optional(string)
    })
  }))
})
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description.

Required if [machine_type](#machine-type-cell) = `controlplane`.

### Cluster Control Plane Input

```hcl
object({
  endpoint           = string
  localAPIServerPort = optional(number)
})
```

See [ControlPlaneConfig](https://www.talos.dev/v1.0/reference/configuration/#controlplaneconfig) section in Talos Configuration Reference for detail description. 

### Cluster Discovery Input

```hcl
object({
  enabled = bool
  registries = optional(object({
    kubernetes = optional(object({
      disabled = bool
    }))
    service = optional(object({
      disabled = bool
      endpoint = string
    }))
  }))
})
```

Default:

```hcl
{
  enabled = true
}
```

See [ClusterDiscoveryConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterdiscoveryconfig) section in Talos Configuration Reference for detail description.

### Control Plane Cluster Configuration Input

```hcl
object({
  network = optional(object({
    cni = optional(object({
      name = string
      urls = optional(list(string))
    }))
    dnsDomain      = optional(string)
    podSubnets     = optional(list(string))
    serviceSubnets = optional(list(string))
  }))
  apiServer = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env                      = optional(map(string))
    certSANs                 = optional(list(string))
    disablePodSecurityPolicy = optional(bool)
    admissionControl = optional(list(object({
      name          = string
      configuration = map(any)
    })))
  }))
  controllerManager = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env = optional(map(string))
  }))
  proxy = optional(object({
    disabled  = bool
    image     = optional(string)
    mode      = optional(string)
    extraArgs = optional(map(string))
  }))
  scheduler = optional(object({
    image     = string
    extraArgs = optional(map(string))
    extraVolumes = optional(list(object({
      hostPath  = string
      mountPath = string
      readonly  = bool
    })))
    env = optional(map(string))
  }))
  etcd = optional(object({
    image     = optional(string)
    extraArgs = optional(map(string))
    subnet    = optional(string)
  }))
  coreDNS = optional(object({
    disabled = bool
    image    = optional(string)
  }))
  externalCloudProvider = optional(object({
    enabled   = bool
    manifests = list(string)
  }))
  adminKubeconfig = optional(object({
    certLifetime = string
  }))
  allowSchedulingOnMasters = optional(bool)
})
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description. 

### Cluster Inline Manifests Input

```hcl
list(object({
  name     = string
  contents = string
}))
```

See [ClusterConfig](https://www.talos.dev/v1.0/reference/configuration/#clusterconfig) section in Talos Configuration Reference for detail description.

## Outputs

| Name | Description | Type | Sensitive |
|---|---|---|---|
| configuration | Base64 encoded Talos configuration. | `string` | `false` |

## Authors

Module is maintained by [Ilya Pozdnov](https://github.com/ilpozzd).

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
