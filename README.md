# k8s backups

Tools to backup stuff running in Kubernetes and upload do S3 compatible buckets.

## How to use Helm Charts

Once [Helm](https://helm.sh/docs/intro/install/) has been set up correctly, add the repo as follows:

    helm repo add k8s-backups https://wcgomes.github.io/k8s-backups

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
k8s-backups` to see the charts.

To install a chart:

### MongoDB

    helm install backup-mongodb k8s-backups/k8s-backups-mongodb -f .\values.yaml 

### Postgresql

    helm install backup-postgresql k8s-backups/k8s-backups-postgresql -f .\values.yaml 

To uninstall the chart:

    helm delete my-<chart-name>