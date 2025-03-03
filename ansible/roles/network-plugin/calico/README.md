# network-plugin/calico role

Installs Calico network plugin.

The configuration is <= 50 nodes with kubernetes API datastore, which described in
[Install Calico networking and network policy for on-premises deployments](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises).

By default, overlay (IP-in-IP / VXLAN) is disabled.

## Variables

* calico_ipv4pool_ipip: Enable IP-in-IP? (default: "Never")
* calico_ipv4pool_vxlan: Enable VXLAN? (default: "Never")
* calico_felix_iptablesbackend: Felix iptables backend (default: "Auto") 

## Note

The `calico.yaml` file is slightly modified to support nftables (RHEL8/CentOS8), 

The `FELIX_IPTABLESBACKEND` is set to `Auto` (Default is `Legacy`) in the yaml file.

```yaml
kind: DaemonSet
...
spec:
  ...
  template:
    ...
    spec:
      ...
      containers:
        - name: calico-node
          ...
          env:
            - name: FELIX_IPTABLESBACKEND
              value: "Auto"
``` 

Refer https://docs.projectcalico.org/reference/felix/configuration for details of the option.
