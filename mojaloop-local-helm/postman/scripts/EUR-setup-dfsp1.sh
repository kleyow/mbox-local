#!/usr/bin/env bash

newman run --delay-request=2000 --folder='dfsp1 (p2p transfers)' --environment=$1 EUR-OSS-New-Deployment-FSP-Setup.postman_collection.json
