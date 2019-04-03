# RIC Integration

This repo contains RAN Intelligent Controller (RIC) deployments related files.


### Directory Structure
- kubernetes: scripts for kubernetes related tasks
- LICENSES.txt:
- localize.sh: a script for inserting localized infrastructure parameters (docker registry host, port, etc) into helm charts and scripts in this repo
- ricplt: RIC Platform Helm charts and related scripts
- runric_env.sh: the env variables for local infrastructure
- xapps: xapps Helm charts and chart templates

### To Generate Localized Charts and Scripts

First we will need to edit the ./runric_env.sh and fill values with local infrastructure parameters.

```sh
$ then run:
$ ./localize.sh
$ cd generated
```

Now the localized scripts and charts are ready to use.
