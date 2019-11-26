The aim of this Document is to have a local mojaloop running with the services we need to run a simple test with Quote, Transfer and Settlement

## create host
add to /etc/hosts
```
127.0.0.1       central-ledger.local central-settlement.local ml-api-adapter.local account-lookup-service.local account-lookup-service-admin.local quoting-service.local moja-simulator.local central-ledger central-settlement ml-api-adapter account-lookup-service account-lookup-service-admin quoting-service simulator host.docker.internal
```

## start the compose
go to mbox-local-mojaloop/mojaloop-docker and run
```
docker-compose up
```

## create some initial data

following the [postman for ML](https://github.com/mojaloop/postman/blob/master/README.md)

### Prerequisites
* Install newman
```
npm install -g newman
```

* clone the project
```
git clone https://github.com/mojaloop/postman.git
```

* Run the pre-loading data
```
sh scripts/setupDockerCompose-HubAccount.sh
newman

OSS-New-Deployment-FSP-Setup

❏ Hub Account
↳ Add Hub Account-HUB_MULTILATERAL_SETTLEMENT
  POST http://central-ledger.local:3001/participants/Hub/accounts [201 Created, 511B, 5.2s]
  ✓  Status code is 201

↳ Add Hub Account-HUB_RECONCILIATION
  POST http://central-ledger.local:3001/participants/Hub/accounts [201 Created, 654B, 36ms]
  ✓  Status code is 201

↳ Hub Set Endpoint-SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL Copy
  POST http://central-ledger.local:3001/participants/hub/endpoints [201 Created, 129B, 1474ms]
  ✓  Status code is 201

↳ Hub Set Endpoint-NET_DEBIT_CAP_ADJUSTMENT_EMAIL Copy
  POST http://central-ledger.local:3001/participants/hub/endpoints [201 Created, 129B, 27ms]
  ✓  Status code is 201

↳ Hub Endpoint-NET_DEBIT_CAP_THRESHOLD_BREACH_EMAIL Copy
  POST http://central-ledger.local:3001/participants/Hub/endpoints [201 Created, 129B, 34ms]
  ✓  Status code is 201

┌─────────────────────────┬─────────────────────┬────────────────────┐
│                         │            executed │             failed │
├─────────────────────────┼─────────────────────┼────────────────────┤
│              iterations │                   1 │                  0 │
├─────────────────────────┼─────────────────────┼────────────────────┤
│                requests │                   5 │                  0 │
├─────────────────────────┼─────────────────────┼────────────────────┤
│            test-scripts │                  10 │                  0 │
├─────────────────────────┼─────────────────────┼────────────────────┤
│      prerequest-scripts │                   5 │                  0 │
├─────────────────────────┼─────────────────────┼────────────────────┤
│              assertions │                   5 │                  0 │
├─────────────────────────┴─────────────────────┴────────────────────┤
│ total run duration: 17.2s                                          │
├────────────────────────────────────────────────────────────────────┤
│ total data received: 809B (approx)                                 │
├────────────────────────────────────────────────────────────────────┤
│ average response time: 1345ms [min: 27ms, max: 5.2s, s.d.: 1985ms] │
└────────────────────────────────────────────────────────────────────┘
```

the same with the other scripts to generate DFSPs

```
sh scripts/setupDockerCompose-PayerFSP.sh
```
and
```
sh scripts/setupDockerCompose-PayeeFSP.sh
```

## Running Example Requests

1. Import the [Golden Path](https://github.com/mojaloop/postman/blob/master/Golden_Path.postman_collection.json) Collection and [Docker-compose Environment](https://github.com/mojaloop/postman/blob/master/environments/Mojaloop-Local-Docker-Compose.postman_environment.json) File.
2. Ensure you select `Mojaloop-Local-Docker-Compose` from the environment drop-down
3. Navigate to `Golden_Path` > `p2p_money_transfer` > `p2p_happy_path SEND Quote` > `Send Transfer`
4. Click **Send**
5. You can check the logs, database, etc to see the transfer state, status changes, positions and other such information.