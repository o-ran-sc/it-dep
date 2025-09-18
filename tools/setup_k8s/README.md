# Kubernetes Auto Deployment 

This tool install kubernetes with its dependencies optimized for O-RAN SC SMO deployment.

## Directory Structure
````
setup_k8s/
├── Makefile              
├── scripts/
│   ├── setup_k8s.sh     # Install k8s, CNI.
│   ├── openebs.sh       # Install OpenEBS local storage class
│   └── chartmuseum.sh   # Install Chartmuseum + plugins
└── README.md               
````


## How to use
```
 make run IP=<ip_address> SUDO=sudo
```