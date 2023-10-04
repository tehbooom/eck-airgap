---
mirrors:
  docker.io:
    endpoint:
      - "https://rke2-airgap-registry.${zone}.c.${project}.internal:5000"
  quay.io:
    endpoint:
      - "https://rke2-airgap-registry.${zone}.c.${project}.internal:5000"
  docker.elastic.co:
    endpoint:
      - "https://rke2-airgap-registry.${zone}.c.${project}.internal:5000"
  registry.access.redhat.com:
    endpoint:
      - "https://rke2-airgap-registry.${zone}.c.${project}.internal:5000"
configs:
  "rke2-airgap-registry.${zone}.c.${project}.internal:5000":
    tls:
      insecure_skip_verify: true
