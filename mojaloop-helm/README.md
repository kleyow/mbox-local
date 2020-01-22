# Local Mojaloop + Custom DFSP Test setup for Kubernetes

Running an independent Kubernetes cluster, to which we will later deploy mojaloop with two customs DFSPs (backend plus sdk-adapter) and a mojaloop simulator.


## Configuration

You can change a lot of parameters of configuration. For example, DFSPs, simulator, database, services, and so on. Try to see [values.yaml](mojaloop/values.yaml). An important option is the Mojaloop can use externals databases. For that, you need to change those values.

* For the Central Ledger's database

| Parameter | Default | Description |
|-----------|---------|-------------|
| `centralLedger.db.host`       | `mysql` | Hostname of database |
| `centralLedger.db.user`       | `central_ledger` | Username for authenticating to database |
| `centralLedger.db.password`   | `password` | Password for `db.user` |
| `centralLedger.db.schema`     | `central_ledger` | Name of database |
| `centralLedger.db.port`       | `3307` | TCP port to connect to database |
| `centralLedger.db.enabled`    | `true` | Enable internal database |


* For the Account lookup's database

| Parameter | Default | Description |
|-----------|---------|-------------|
| `accountLookUp.db.host`       | `mysql-als` | Hostname of database |
| `accountLookUp.db.user`       | `account_lookup` | Username for authenticating to database |
| `accountLookUp.db.password`   | `password` | Password for `db.user` |
| `accountLookUp.db.schema`     | `account_lookup` | Name of database |
| `accountLookUp.db.port`       | `3306` | TCP port to connect to database |
| `accountLookUp.db.enabled`    | `true` |  Enable internal database |


## Deploying Mojaloop

1. Install `helm` version 2.16.
    * Ubuntu:
        ```
        snap install --channel=2.16 helm --classic
        ```
    * macOS:
        ```
        brew install kubernetes-helm
        ```
        ```
        brew unlink kubernetes-helm
        ```
        ```
        brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/2fbed24cb83d0ecc69b8004e69027e0d8eed5f9d/Formula/kubernetes-helm.rb
        ```
        ```
        brew switch kubernetes-helm 2.16.1        
        ```
    * [Other environments](https://helm.sh/docs/using_helm/#installing-helm)

2. Initialise `helm` with
    ```
    helm init
    ```

3. Wait until Tiller (the Helm in-cluster service) is available by running
    ```
    kubectl -n kube-system wait --for=condition=Ready pod -l name=tiller --timeout=300s
    ```

4. Set up Tiller cluster role.
    ```sh
    kubectl create serviceaccount -n kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    kubectl --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    ```

5. Install Mojaloop with `helm` using
    ```sh
    cd mbox-local-mojaloop/mojaloop-helm
    ```

    ```sh
    helm install --name mojaloop --debug ./mojaloop/
    ```

6. Ensure all pods are running with
    ```
    kubectl get pods
    ```
    after a few minutes to allow for the usual startup time.

7. We need to check if account-services is running for that reason we'll execute this health request

    ```
    curl -X GET http://<<clauster ip>>:30401/health
    ```
    
    If you are using a docker-desktop then

    ```
    curl -X GET http://kubernetes.docker.internal:30401/health
    ```

    If this response is "OK", we can continue with the next step otherwise we need to delete this pod. First we need to find it

    ```
    kubectl get pods

    NAME                                               READY   STATUS     RESTARTS   AGE
    dfsp1-scheme-adapter-695cb9bdb4-gkwl8              1/1     Running    0          20s
    dfsp2-scheme-adapter-7dffbbd8fd-nspp4              1/1     Running    0          20s
    kafka-575687498d-9nn9j                             1/1     Running    0          15s
    mojaloop-account-lookup-service-7cf4d7d4d6-w7566   1/1     Running    0          20s
    mojaloop-bankofamerica-backend-7f4bb96f66-xtfbf    1/1     Running    0          18s
    mojaloop-bankofamerica-redis-7ddf577544-ft7z2      1/1     Running    0          17s
    ```
    In this case , we'll delete  **mojaloop-account-lookup-service-7cf4d7d4d6-w7566**

    ```
    kubectl delete pods mojaloop-account-lookup-service-7cf4d7d4d6-w7566
    ```

## Create some initial data

### Prerequisites

* Install newman

```
npm install -g newman
```

* Run the pre-loading data

    * cd into postman folder and run
 
```
sh scripts/setupDockerCompose-HubAccount.sh
```

```
Expected output:
```

```
OSS-New-Deployment-FSP-Setup

❏ Hub Account
↳ Add Hub Account-HUB_MULTILATERAL_SETTLEMENT
  POST kubernetes.docker.internal:30001/participants/Hub/accounts [201 Created, 529B, 199ms]
  ✓  Status code is 201

↳ Add Hub Account-HUB_RECONCILIATION
  POST kubernetes.docker.internal:30001/participants/Hub/accounts [201 Created, 672B, 55ms]
  ✓  Status code is 201

↳ Hub Set Endpoint-SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL Copy
  POST kubernetes.docker.internal:30001/participants/hub/endpoints [201 Created, 129B, 1121ms]
  ✓  Status code is 201

↳ Hub Set Endpoint-NET_DEBIT_CAP_ADJUSTMENT_EMAIL Copy
  POST kubernetes.docker.internal:30001/participants/hub/endpoints [201 Created, 129B, 46ms]
  ✓  Status code is 201

↳ Hub Endpoint-NET_DEBIT_CAP_THRESHOLD_BREACH_EMAIL Copy
  POST kubernetes.docker.internal:30001/participants/Hub/endpoints [201 Created, 129B, 47ms]
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
│ total run duration: 12.2s                                          │
├────────────────────────────────────────────────────────────────────┤
│ total data received: 845B (approx)                                 │
├────────────────────────────────────────────────────────────────────┤
│ average response time: 293ms [min: 46ms, max: 1121ms, s.d.: 417ms] │
└────────────────────────────────────────────────────────────────────┘
```

```
sh scripts/setupDockerCompose-OracleOnboarding.sh
```

```
OSS-New-Deployment-FSP-Setup

❏ Oracle Onboarding
↳ Register Simulator Oracle for MSISDN
  POST kubernetes.docker.internal:30401/oracles [201 Created, 213B, 180ms]

┌─────────────────────────┬────────────────────┬───────────────────┐
│                         │           executed │            failed │
├─────────────────────────┼────────────────────┼───────────────────┤
│              iterations │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│                requests │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│            test-scripts │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│      prerequest-scripts │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│              assertions │                  0 │                 0 │
├─────────────────────────┴────────────────────┴───────────────────┤
│ total run duration: 2.4s                                         │
├──────────────────────────────────────────────────────────────────┤
│ total data received: 0B (approx)                                 │
├──────────────────────────────────────────────────────────────────┤
│ average response time: 180ms [min: 180ms, max: 180ms, s.d.: 0µs] │
└──────────────────────────────────────────────────────────────────┘
```


### Create a CitiBank DFSP (use SDK + backend)
```
$ sh scripts/setupDockerCompose-DFSP-CITIBANK.sh
```

### Create a Bank Of America DFSP (use SDK + backend)
```
$ sh scripts/setupDockerCompose-DFSP-BANK-OF-AMERICA.sh
```

### Create a Simulator DFSP (implement mojaloop api)
```
$ sh scripts/setupDockerCompose-DFSP-SIMULATOR.sh
```

### Add MSISDN (123456789) for CitiBank DFSP
```
$ sh scripts/setupDockerCompose-DFSP-CITIBANK-MSISDN.sh
```

### Add MSISDN (987654321) for Bank Of America DFSP
```
$ sh scripts/setupDockerCompose-DFSP-BANK-OF-AMERICA-MSISDN.sh
```

### Add MSISDN (333333333) for Simulator
```
$ sh scripts/setupDockerCompose-DFSP-SIMULATOR-MSISDN.sh
```

## Examples

* Transfer USD 100 from MSIDNS 123456789 (CITIBANK) to MSIDNS 987654321 (Bank Of America)

```
curl -v -X POST http://kubernetes.docker.internal:30900/send   -H 'Content-Type: application/json'  -d '{
    "from": {
        "displayName": "Livia",
        "idType": "MSISDN",
        "idValue": "123456789"
    },
    "to": {
        "idType": "MSISDN",
        "idValue": "987654321"
    },
    "amountType": "SEND",
    "currency": "USD",
    "amount": "100",
    "transactionType": "TRANSFER",
    "note": "test",
    "homeTransactionId": "123ABC"
}'
```

### Response: Transfer was completed
```
{
"from":{
    "displayName":"Livia",
    "idType":"MSISDN",
    "idValue":"123456789"
},
"to":{
    "idType":"MSISDN",
    "idValue":"987654321",
    "fspId":"bankofamerica",
    "firstName":"Jane",
    "middleName":"Someone",
    "lastName":"Doe",
    "dateOfBirth":"1982-02-02"
    },
    "amountType":"SEND",
    "currency":"USD",
    "amount":"100",
    "transactionType":"TRANSFER",
    "note":"test",
    "homeTransactionId":"123ABC",
    "transferId":"addda412-d95f-4424-9778-e29a517d15ef",
    "currentState":"COMPLETED",
    "quoteId":"6a5ae0b4-fb0a-4c89-9a9a-210303d42f34",
    "quoteResponse":{
        "transferAmount":{
            "amount":"100",
            "currency":"USD"
        },
        "expiration":"2020-01-03T17:45:13.613Z",
        "ilpPacket":"AYIDKAAAAAAAACcQIGcuYmFua29mYW1lcmljYS5tc2lzZG4uOTg3NjU0MzIxggL7ZXlKMGNtRnVjMkZqZEdsdmJrbGtJam9pWVdSa1pHRTBNVEl0WkRrMVppMDBOREkwTFRrM056Z3RaVEk1WVRVeE4yUXhOV1ZtSWl3aWNYVnZkR1ZKWkNJNklqWmhOV0ZsTUdJMExXWmlNR0V0TkdNNE9TMDVZVGxoTFRJeE1ETXdNMlEwTW1Zek5DSXNJbkJoZVdWbElqcDdJbkJoY25SNVNXUkpibVp2SWpwN0luQmhjblI1U1dSVWVYQmxJam9pVFZOSlUwUk9JaXdpY0dGeWRIbEpaR1Z1ZEdsbWFXVnlJam9pT1RnM05qVTBNekl4SWl3aVpuTndTV1FpT2lKaVlXNXJiMlpoYldWeWFXTmhJbjBzSW5CbGNuTnZibUZzU1c1bWJ5STZleUpqYjIxd2JHVjRUbUZ0WlNJNmV5Sm1hWEp6ZEU1aGJXVWlPaUpLWVc1bElpd2liV2xrWkd4bFRtRnRaU0k2SWxOdmJXVnZibVVpTENKc1lYTjBUbUZ0WlNJNklrUnZaU0o5TENKa1lYUmxUMlpDYVhKMGFDSTZJakU1T0RJdE1ESXRNRElpZlgwc0luQmhlV1Z5SWpwN0luQmhjblI1U1dSSmJtWnZJanA3SW5CaGNuUjVTV1JVZVhCbElqb2lUVk5KVTBST0lpd2ljR0Z5ZEhsSlpHVnVkR2xtYVdWeUlqb2lNVEl6TkRVMk56ZzVJaXdpWm5Od1NXUWlPaUpqYVhScFltRnVheUo5TENKdVlXMWxJam9pVEdsMmFXRWlmU3dpWVcxdmRXNTBJanA3SW1GdGIzVnVkQ0k2SWpFd01DSXNJbU4xY25KbGJtTjVJam9pVlZORUluMHNJblJ5WVc1ellXTjBhVzl1Vkhsd1pTSTZleUp6WTJWdVlYSnBieUk2SWxSU1FVNVRSa1ZTSWl3aWFXNXBkR2xoZEc5eUlqb2lVRUZaUlZJaUxDSnBibWwwYVdGMGIzSlVlWEJsSWpvaVEwOU9VMVZOUlZJaWZYMAA",
        "condition":"OzHLWMTIkkfwicr0XPJRXlxhf8iUSGmUbBFCjccbGkI",
        "payeeReceiveAmount":{
            "amount":"100",
            "currency":"USD"
        }
    },
    "quoteResponseSource":"bankofamerica",
    "fulfil":{
        "completedTimestamp":"2020-01-03T17:45:17.854Z",
        "transferState":"COMMITTED",
        "fulfilment":"QsjWcnwZwp8JsSy7D2yTzHtQ9je1_TbDOXqrbR4uvPI"
    }
}

```

* Transfer USD 90 from MSIDNS 987654321 (BANKOFAMERICA) to MSIDNS 333333333 (Simulator)

```
curl -v -X POST http://kubernetes.docker.internal:30100/send   -H 'Content-Type: application/json'  -d '{
    "from": {
        "displayName": "Jose",
        "idType": "MSISDN",
        "idValue": "987654321"
    },
    "to": {
        "idType": "MSISDN",
        "idValue": "333333333"
    },
    "amountType": "SEND",
    "currency": "USD",
    "amount": "90",
    "transactionType": "TRANSFER",
    "note": "test",
    "homeTransactionId": "123ABC"
}'
```

### Response: Transfer was completed

```
{
"from":{
    "displayName":"Jose",
    "idType":"MSISDN",
    "idValue":"987654321"
},
"to":{
    "idType":"MSISDN",
    "idValue":"333333333",
    "fspId":"payeefsp",
    "firstName":"Aruna",
    "lastName":"Switch",
    "dateOfBirth":"1982-02-01"
},
"amountType":"SEND",
"currency":"USD",
"amount":"90",
"transactionType":"TRANSFER",
"note":"test",
"homeTransactionId":"123ABC",
"transferId":"9cb4e2fb-c1e5-47a7-8ab1-f7d9ee35998d",
"currentState":"COMPLETED",
"quoteId":"19ae5c0e-fa30-4319-8762-8315161ada3c",
"quoteResponse":{
    "transferAmount":{
    "amount":"90",
    "currency":"USD"
    },
    "payeeFspFee":{
        "amount":"1",
        "currency":"USD"
    },
    "payeeFspCommission":{
        "amount":"1",
        "currency":"USD"
    },
    "expiration":"2020-01-03T19:11:34.617Z",
    "ilpPacket":"AQAAAAAAAADIEHByaXZhdGUucGF5ZWVmc3CCAiB7InRyYW5zYWN0aW9uSWQiOiIyZGY3NzRlMi1mMWRiLTRmZjctYTQ5NS0yZGRkMzdhZjdjMmMiLCJxdW90ZUlkIjoiMDNhNjA1NTAtNmYyZi00NTU2LThlMDQtMDcwM2UzOWI4N2ZmIiwicGF5ZWUiOnsicGFydHlJZEluZm8iOnsicGFydHlJZFR5cGUiOiJNU0lTRE4iLCJwYXJ0eUlkZW50aWZpZXIiOiIyNzcxMzgwMzkxMyIsImZzcElkIjoicGF5ZWVmc3AifSwicGVyc29uYWxJbmZvIjp7ImNvbXBsZXhOYW1lIjp7fX19LCJwYXllciI6eyJwYXJ0eUlkSW5mbyI6eyJwYXJ0eUlkVHlwZSI6Ik1TSVNETiIsInBhcnR5SWRlbnRpZmllciI6IjI3NzEzODAzOTExIiwiZnNwSWQiOiJwYXllcmZzcCJ9LCJwZXJzb25hbEluZm8iOnsiY29tcGxleE5hbWUiOnt9fX0sImFtb3VudCI6eyJjdXJyZW5jeSI6IlVTRCIsImFtb3VudCI6IjIwMCJ9LCJ0cmFuc2FjdGlvblR5cGUiOnsic2NlbmFyaW8iOiJERVBPU0lUIiwic3ViU2NlbmFyaW8iOiJERVBPU0lUIiwiaW5pdGlhdG9yIjoiUEFZRVIiLCJpbml0aWF0b3JUeXBlIjoiQ09OU1VNRVIiLCJyZWZ1bmRJbmZvIjp7fX19",
    "condition":"HOr22-H3AfTDHrSkPjJtVPRdKouuMkDXTR4ejlQa8Ks"
    },
    "quoteResponseSource":"payeefsp",
    "fulfil":{
        "fulfilment":"XoSz1cL0tljJSCp_VtIYmPNw-zFUgGfbUqf69AagUzY",
        "completedTimestamp":"2020-01-03T19:11:25.966Z",
        "transferState":"COMMITTED"
    }
}
```

