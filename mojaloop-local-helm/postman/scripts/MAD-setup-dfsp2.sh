#!/usr/bin/env bash

newman run --delay-request=2000 --folder='dfsp2 (p2p transfers)' --environment=$1 MAD-OSS-New-Deployment-FSP-Setup.postman_collection.json
