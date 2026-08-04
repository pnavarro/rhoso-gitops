# RHOSO GitOps

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Validated Pattern for deploying [Red Hat OpenStack Services on OpenShift](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/)
(RHOSO) on a single OpenShift cluster using GitOps. It is designed to be
deployed with the [Validated Patterns](https://validatedpatterns.io/) framework
and operator.

## Documentation

| Topic | Link |
| --- | --- |
| Pattern overview and architecture | [rhoso-gitops](https://validatedpatterns.io/patterns/rhoso-gitops/) |
| Getting started (prerequisites, install, verification) | [getting-started](https://validatedpatterns.io/patterns/rhoso-gitops/getting-started/) |
| Cluster sizing | [cluster-sizing](https://validatedpatterns.io/patterns/rhoso-gitops/cluster-sizing/) |
| Configuration (values layers, pinning revisions, secrets) | [configuration](https://validatedpatterns.io/patterns/rhoso-gitops/configuration/) |
| Troubleshooting | [troubleshooting](https://validatedpatterns.io/patterns/rhoso-gitops/troubleshooting/) |

## Chart layout

- `charts/all/rhoso-gitops/` -- pattern meta-chart (see
  [charts/all/rhoso-gitops/README.md](charts/all/rhoso-gitops/README.md) for values
  and overrides)
- `charts/region/` -- reserved for future region-specific charts

## See also

- [Validated Patterns documentation](https://validatedpatterns.io/)
