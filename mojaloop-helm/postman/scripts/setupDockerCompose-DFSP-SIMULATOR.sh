#!/usr/bin/env bash

newman run --delay-request=2000 --folder='payeefsp (p2p transfers)' --environment=environments/Mojaloop-Local-Docker-Compose.postman_environment_DFSP_SIMULATOR.json OSS-New-Deployment-FSP-Setup.postman_collection_DFSPs.json
