#!/usr/bin/env bash

newman run --delay-request=2000 --folder='Oracle Onboarding-MSISDN-BANKOFAMERICA' --environment=environments/Mojaloop-Local-Docker-Compose.postman_environment_DFSP_PAYEE.json OSS-New-Deployment-FSP-Setup.postman_collection_DFSPs.json
