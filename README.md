# ECK Air-Gap Demo

This is a demo of how to deploy ECK and its dependencies in an air-gapped environment

This repo is for demo purposes only and should not be used in production

SELinux is not enabled for the RKE2 cluster and is not enforcing the CIS 1.23 Kubernetes Benchmark

> :warning: **The deployment of this repo takes almost 2 hours due to the RKE2 playbook and the large containers needed to download, tag, and push**

## Known Issues

During development, the second RKE2 server continued to fail on the initial boot. Once I restarted the `rke2-server` service it would work. There is an additional task in the existing RKE2 playbooks which differs from their playbook if you wish to implement a similar architecture

```yaml
# ansible/roles/rke2_server/other-servers.yml
- name: Start rke2-server
    ansible.builtin.systemd:
    name: rke2-server
    state: started
    enabled: true
    timeout: 120
    ignore_errors: true

- name: Restart rke2-server
    ansible.builtin.systemd:
    name: rke2-server
    state: restarted
```

## Pre-requsites

- ansible 2.15.2+
- terraform v1.5.7+
- kubectl v1.25.4+
- [MaxMind license key](http://dev.maxmind.com/geoip/geoip2/geolite2/)

## Steps

1. Create ssh key pair with a password

    > This has to be done since a STIGd RHEL 8 does not allow passwordless login

    ```bash
    ssh-keygen
    ```

2. Update [auto.tfvars](./tf/auto.tfvars) with your variables

    ```hcl
    gcp_region="us-east1"
    gcp_zone = "us-east1-c"
    gce_ssh_pub_key_file = "ssh-rsa AAAAB...= "
    project = "air-gap-demo"
    workers = 5
    servers = 3
    ```

3. You must have your Google credentials as an environment variable follow [this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference.html#running-terraform-on-your-workstation) guide for instructions

    ```bash
    export GOOGLE_CREDENTIALS=<path_to_downloaded_json>
    ```
  
4. Deploy the infrastructure

    ```bash
    terraform -chdir=terraform/ apply -var-file=auto.tfvars -auto-approve
    ```

5. Configure RKE2

   ```bash
   eval "$(ssh-agent -s)"
   ssh-add /path/to/your/ssh_key
   cd ansible
   ansible-galaxy install -r requirements.yaml
   ansible-playbook -i hosts.ini rke2.yml --private-key=/path/to/your/ssh_key --extra-vars "LICENSE=<your_maxmind_license>"
   ```

6. Export the downloaded config and verify your cluster is ready

   ```bash
   export KUBECONFIG=<absolute_path_to>/ansible/config
   cd ..
   kubectl get nodes
   ```

7. Deploy certmanager

    ```bash
    kubectl apply -f k8s/cert-manager/cert-manager.yaml
    # wait for cert-manager to be ready
    kubectl apply -f k8s/cert-manager/ca-issuer.yaml
    ```

8. Deploy longhorn (Ensure you update the images to point to your registry as explained [here](https://longhorn.io/docs/1.5.1/advanced-resources/deploy/airgap/); find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/longhorn/longhorn.yaml
    kubectl apply -f k8s/longhorn/ingress.yaml
    ```

9. Deploy ECK CRDs

    ```bash
    kubectl apply -f k8s/eck/00_crds.yaml
    ```

10. Deploy ECK operator (Update the image to point to your registry and add your registry to the config map)

    ```yaml
    data:
    eck.yaml: |-
        log-verbosity: 0
        metrics-port: 0
        container-registry: "<your_registry_here>:5000"
    ---
    spec:
      terminationGracePeriodSeconds: 10
      serviceAccountName: elastic-operator
      securityContext:
        runAsNonRoot: true
      containers:
      - image: "<your_registry_here>:5000/elastic/eck-operator:2.9.0"
    ```

    ```bash
    kubectl apply -f k8s/eck/01_operator.yaml
    ```

11. Deploy Elastic license

    ```bash
    kubectl apply -f k8s/eck/02_license.yaml
    ```

12. Deploy namespaces

    ```bash
    kubectl apply -f k8s/eck/03_namespaces.yaml
    ```

13. Deploy Elastic Package Registry (Update the image to point to your registry; find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/eck/epr/epr.yaml
    ```

14. Deploy Elastic Artifact Registry (Update the image to point to your registry; find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/eck/ear/ear.yaml
    ```

15. Deploy Elastic Endpoint Artifact Repository (Update the image to point to your registry; find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/eck/eer/eer.yaml
    ```

16. Deploy Elastic Learned Sparse EncodeR (Update the image to point to your registry; find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/eck/elser/elser.yaml
    ```

17. Deploy GeoIP database (Update the image to point to your registry; find and replace <your_registry_here>)

    ```bash
    kubectl apply -f k8s/eck/geoip/geoip.yaml
    ```

18. Deploy monitor cluster

    ```bash
    kubectl apply -f k8s/eck/04_monitor.yaml
    ```

19. Deploy production cluster

    ```bash
    kubectl apply -f k8s/eck/05_prod.yaml
    ```

20. Deploy Fleet server (wait for prod cluster to be ready)

    ```bash
    kubectl apply -f k8s/eck/06_fleet.yaml
    ```

21. Deploy Elastic Maps Service

    ```bash
    kubectl apply -f k8s/eck/07_maps.yaml
    ```

22. Update `/etc/hosts` with your loadbalancers external IP (found in [hosts.ini](ansible/hosts.ini) or in the GCP console) and FQDN to your services

    ```bash
    echo "<your_lb_external_ip> longhorn.air-gap.demo monitor.air-gap.demo prod.air-gap.demo maps.air-gap.demo" >> /etc/hosts
    ```

23. Get credentials

    ```bash
    kubectl get secret monitor-es-elastic-user -o go-template='{{.data.elastic | base64decode}}' -n monitor
    kubectl get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}' -n prod
    ```

24. Login to your clusters! Ensure you update the default Elastic Artifact Registry and the path to Elastic Endpoint Artifact Repository in Kibana

    > You may need to add an ingress for each of these services if Agents outside the k8s cluster need access

## Security

This demo does not provide all the best security practices. Here are just a few things to keep in mind if you want to deploy in production.

- Ensure you have SELinux enabled for RKE2 and the host
- Add the CIS 1.23 profile
- Update container security context (Some containers in this demo were updated)
- Enforce network policies to segment the cluster
- Use hardened images from Iron Bank
