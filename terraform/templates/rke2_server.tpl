---
rke2_config:
  token: "${token}"
  write-kubeconfig-mode: "0640"
  tls-san:
    - "rke2-airgap-lb.${zone}.c.${project}.internal"
    - "${ip}"
  node-taint:
    - "CriticalAddonsOnly=true:NoExecute"
registry_config_file_path: "{{ playbook_dir }}/registries.yml"
