# RIC Platform Installation
### Directory Structure
├── charts
│   ├── appmgr: xApp Manager Helm Chart
│   ├── common: Common Helm Chart
│   ├── dbaas: Database as a Service Helm Chart
│   ├── e2mgr: E2 Termination Manager Helm Chart
│   ├── e2term: E2 Termination Helm Chart
│   ├── preric: Pre-RIC Helmn Chart (for setting infrastructure resources such as docker registry credential)
│   ├── ric: RIC Helm Chart
│   └── rtmgr: Routing Manager Helm Chart
├── README.md
└── scripts
    ├── helm\_reset.sh: Script to reset the helm environment
    ├── prepull.sh: Scriptr for pre-pulling all RIC platform component docker images
    ├── ric\_env.sh: Script for setting up various env varibles needed for RIC
    ├── ric\_install.sh: RIC "one-click" installation script
    └── ric\_uninstall.sh: RIC uninstallation


### To Install RIC Platform Deployment
```sh
$ # set environment variables
$ . ./scripts/ric_env.sh
$ # reset helm and local chart repo
$ ./scripts/helm_reset.sh
$ # install RIC platform
$ ./scripts/ric_install.sh
```

### To Unnstall RIC Platform Deployment
```sh
$ # uninstall RIC platform
$ ./scripts/ric_uninstall.sh
```

