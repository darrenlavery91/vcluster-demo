# vCluster Demo

## Prerequisites

Please ensure the following tools are installed on your machine:

- **Ansible**
- **Kind**
- **Docker** or **Podman**
- **Kubectl**
- **Helm** (version 3.x or higher)
- **Terraform**

## Run Ansible Playbook

To start, run the following Ansible playbook:

```bash
ansible-playbook kind_build.yaml
```

This will build a Kind cluster on your local machine.

## Install vCluster using Terraform

To install vCluster, you can use Terraform. Follow these steps:

1. Navigate to the Terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the Terraform plan:
   ```bash
   terraform plan
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

This Terraform play will create two vCluster:

- **Giffindor**
- **Slytherin**

## Connect to a vCluster

To connect to a vCluster, use the following command:

```bash
vcluster connect "clustername" --namespace "ns-name"
```

Once connected, you can check the status of the vClusters' using:

```bash
vcluster list
```

Example output:

```
           NAME         | NAMESPACE  | STATUS  | VERSION | CONNECTED |  AGE
  ----------------------+------------+---------+---------+-----------+---------
    gryffindor-vcluster | gryffindor | Running | 0.23.0  | True      | 50m25s
    slytherin-vcluster  | slytherin  | Running | 0.23.0  | True      | 50m30s
```

## Switch Config Context

To switch between Vcluster contexts, use `kubectl`:

1. List available contexts:
   ```bash
   kubectl config get-contexts
   ```

2. Switch to the desired context:
   ```bash
   kubectl config use-context "name"
   ```

   Example:
   ```bash
   kubectl config use-context vcluster_gryffindor-vcluster_gryffindor_kind-kube-cluster01
   ```

## Apply Roles

To apply roles, run the following commands:

1. For **Gryffindor**:
   ```bash
   kubectl apply -f gryffindor_vcluster_roles.yaml
   ```

2. For **Slytherin**, repeat the same for their vCluster:
   ```bash
   kubectl apply -f slytherin_vcluster_roles.yaml
   ```

## Verify Permissions

To verify that **Harry** and **Malfoy** have distinct permissions, switch to the vCluster contexts for **team1** and **team2**.

1. Test Harry's permissions in their vCluster:
   ```bash
   kubectl auth can-i create deployments --namespace=default --as=Harry
   ```
   Expected result: `yes`

2. Test Malfoy's permissions in their vCluster:
   ```bash
   kubectl auth can-i create deployments --namespace=default --as=Malfoy
   ```
   Expected result: `no`

This confirms that team-specific permissions are respected, showcasing the power of vClusters in enforcing isolated RBAC configurations.

## Change Context to Specific User

Switch to the **Kind** or main cluster that is hosting the vClusters, then run:

```bash
kubectl config set-context harry-context \
  --cluster=vcluster_gryffindor-vcluster_gryffindor_kind-kube-cluster01  \
  --namespace=gryffindor \
  --user=vcluster_gryffindor-vcluster_gryffindor_kind-kube-cluster01  \
  --username="harry" \
  --password="voldermort"
```