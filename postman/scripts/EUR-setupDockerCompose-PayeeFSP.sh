#!/usr/bin/env bash

newman run --delay-request=2000 --folder='dfspeur (p2p transfers)' --environment=environments/EUR-Mojaloop-Local-Docker-Compose.postman_environment.json EUR-OSS-New-Deployment-FSP-Setup.postman_collection.json
