[rke2_servers]
%{ for index, ip in ip_server ~}
rke2-airgap-server-${index + 1}.${zone}.c.${project}.internal ansible_host=${ip}
%{ endfor ~}


[rke2_agents]
%{ for index, ip in ip_worker ~}
rke2-airgap-worker-${index + 1}.${zone}.c.${project}.internal ansible_host=${ip}
%{ endfor ~}

[registry]
%{ for index, ip in ip_registry ~}
rke2-airgap-registry.${zone}.c.${project}.internal ansible_host=${ip}
%{ endfor ~}

[loadbalancer]
%{ for index, ip in ip_lb ~}
rke2-airgap-lb.${zone}.c.${project}.internal ansible_host=${ip}
%{ endfor ~}

[rke2_cluster:children]
rke2_servers
rke2_agents

[all:vars]
install_rke2_version = v1.27.4+rke2r1
kubernetes_api_server_host = "rke2-airgap-lb.${zone}.c.${project}.internal"