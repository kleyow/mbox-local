# MOJALOOP Helm Chart  (with quoting Service multicurrency)

The quoting service has some rules defined. These rules make it possible to request a quote (or transfer) with different currencies. Now, It is possible to send and receive these currencies: EUR and MAD. If you want to add a new one, see below. These rules are defined [here](./mojaloop/templates/quoting-service-configmap.yaml).

## Start a local mojaloop 

For simplicity, this helm chart has to deploy in the same namespace as FXP. Because Quoting Service needs to invoke FXP for multicurrency.

```
$ helm install --name mojaloop --namespace fxp  --debug ./mojaloop/
```

Then, check all pods have already run

```
$ kubectl get pods -n fxp

NAME                                                          READY   STATUS    RESTARTS   AGE
fxp-scheme-adapter-mysql-f6585496-745vt                       1/1     Running   0          179m
fxp-server-mysql-576b544777-r42wh                             1/1     Running   0          179m
kafka-d57987749-n9nqj                                         1/1     Running   0          178m
mbox-fxp-mojaloop-fxp-adapter-5d54689678-svhsh                1/1     Running   2          179m
mbox-fxp-mojaloop-fxp-portx-routing-engine-5df679dcd6-bsxjg   1/1     Running   0          179m
mbox-fxp-mojaloop-fxp-redis-77f9cfcc75-cp9q5                  1/1     Running   0          179m
mbox-fxp-mojaloop-fxp-server-78c9989976-6fm5c                 1/1     Running   0          179m
mbox-fxp-mojaloop-fxp-sftp-97dcf76b9-77w7m                    1/1     Running   0          179m
mbox-fxp-mojaloop-fxp-tmf-67c4cb6688-zsz94                    1/1     Running   0          179m
mbox-tmf-mysql-68c4f58d74-59r9f                               1/1     Running   0          179m
mojaloop-account-lookup-service-86c85d79ff-6hk8f              1/1     Running   3          178m
mojaloop-central-ledger-6c6bd46fd8-vz4p5                      1/1     Running   3          178m
mojaloop-central-settlement-78f5f4596b-t5w67                  1/1     Running   4          178m
mojaloop-ml-api-adapter-7f7d58685-6tggm                       1/1     Running   0          178m
mojaloop-quoting-service-7d69868bd8-tmlw2                     1/1     Running   0          178m
mojaloop-simulator-6bf6d5f57f-qbjlb                           1/1     Running   0          178m
mysql-68ff976458-srpmx                                        1/1     Running   0          178m
mysql-als-64f486c559-sdc2p                                    1/1     Running   0          178m

```




## Onboarding

Choose test o local environment and pass as a parameter to those scripts.

First go to folder postman

```
cd postman/
```

Then execute those scripts for currency EUR in a specific environment. 

For example __Local enviroment__ 

__HUB EUR__ Onboarding

```
sh scripts/EUR-setup-HubAccount.sh  environments/local/EUR-Mojaloop-Local-Docker-Compose.postman_environment.json
```

__DFSP EUR: dfsp1__ Onboarding

```
sh scripts/EUR-setup-dfsp1.sh  environments/local/EUR-Mojaloop-Local-Docker-Compose.postman_environment.json
```


__Virtual DFSP EUR: DFSPEUR__ Onboarding

```
sh scripts/EUR-setup-virtual-DFSPEUR.sh  environments/local/EUR-Mojaloop-Local-Docker-Compose.postman_environment.json
```


and those scripts for currency MAD 

__HUB MAD__ Onboarding

```
sh scripts/MAD-setup-HubAccount.sh  environments/local/MAD-Mojaloop-Local-Docker-Compose.postman_environment.json
```

__DFSP MAD: dfsp2__ Onboarding

```
sh scripts/MAD-setup-dfsp2.sh environments/local/MAD-Mojaloop-Local-Docker-Compose.postman_environment.json
```

__Virtual DFSP MAD: DFSPMAD__ Onboarding

```
sh scripts/MAD-setup-virtual-DFSPMAD.sh   environments/local/MAD-Mojaloop-Local-Docker-Compose.postman_environment.json
```


# Testing 

Before we execute a quote from dfsp1 (EUR) to dfsp2 (MAD). We need to check if FXP has an exchange rate for those currencies. So, we can execute this query (change the IP where FXP is deployed)

```
curl -X GET "http://kubernetes.docker.internal:30080/exchange-rates/channels/" -H 'Accept: application/json' -H 'Content-Type: application/json' 

[
  {
    "id": 1,
    "sourceCurrency": "EUR",
    "destinationCurrency": "XOF",
    "status": "Approved",
    "createdBy": null,
    "createdDate": "2020-02-28T13:22:01.000Z"
  },
  {
    "id": 2,
    "sourceCurrency": "EUR",
    "destinationCurrency": "MAD",
    "status": "Approved",
    "createdBy": null,
    "createdDate": "2020-02-28T13:22:01.000Z"
  }
]
```

and then, we check if there are rates for the channel __2__

```
 curl -X GET "http://kubernetes.docker.internal:30080/exchange-rates/channels/2/rates" -H 'Accept: application/json' -H 'Content-Type: application/json' 

 [
  {
    "rate": 16543,
    "decimalRate": 4,
    "startTime": "2020-02-07T14:49:02.000Z",
    "endTime": "2020-12-07T14:49:02.000Z",
    "reuse": true,
    "channelId": 2,
    "id": 2,
    "forexProviderInfo": {
      "citi": {
        "citiExchangeRateId": 1,
        "exchangeRateId": 2,
        "rateSetId": 42,
        "currencyPair": "EURMAD",
        "tenor": "TN",
        "bidSpotRate": "1.6543",
        "offerSpotRate": "1.7543",
        "midPrice": "1.7043",
        "validUntilTime": "2020-12-07T14:49:02.000Z",
        "isValid": true,
        "baseCurrency": "EUR",
        "ratePrecision": 4,
        "invRatePrecision": 1,
        "isTradable": true,
        "valueDate": "2020-12-07",
        "createdDate": "2020-02-28T12:34:57.368Z",
        "createdBy": "admin"
      }
    }
  }
]
```


If you do not have rates for this channel, you need to execute this post;

```
 curl -X POST "http://localhost:30080/exchange-rates/channels/2/rates" -H 'Accept: application/json' -H 'Content-Type: application/json' -d "{ \"rate\": 16543, \"decimalRate\": 4, \"startTime\": \"2020-02-07T14:49:02.000Z\", \"endTime\": \"2020-12-07T14:49:02.000Z\", \"reuse\": true, \"forexProviderInfo\": { \"citi\": { \"rateSetId\": \"42\", \"currencyPair\": \"EURMAD\", \"baseCurrency\": \"EUR\", \"ratePrecision\": \"4\", \"invRatePrecision\": \"1\", \"tenor\": \"TN\", \"valueDate\": \"2020-12-07\", \"bidSpotRate\": \"1.6543\", \"offerSpotRate\": \"1.7543\", \"midPrice\": \"1.7043\", \"validUntilTime\": \"2020-12-07 14:49:02.000\", \"isValid\": \"true\", \"isTradable\": \"true\" } }}"
```


Now, We can execute a quote request. You can go to Postman and open [this](./postman/collections/SendQuoteAndTransferEUR-MAD.postman_collection.json) collection and select __Send Quote_SEND EUR__. Be careful about the environment selected. 

If you see logs in quoting service, you see something similar like this 


```
{
    "transferAmount":{
        "amount":"10000",
        "currency":"EUR"
    },
    "payeeFspFee":{
        "amount":"1",
        "currency":"MAD"
    },
    "payeeFspCommission":{
        "amount":"1",
        "currency":"MAD"
    },
    "expiration":"2020-02-28T16:51:47.204Z",
    "ilpPacket":"AYICyAAAAAAAD0JAEGcuZGZzcDIubXNpc2RuLjKCAqtleUowY21GdWMyRmpkR2x2Ymtsa0lqb2lZVFZqTVRjNVl6Z3RaamMzWlMwME1ERXlMVGxrTTJJdE1UazJNVFUzWmpobU9UZ3lJaXdpY1hWdmRHVkpaQ0k2SW1NeU1UWTRNakU1TFdFeFpEa3ROR0pqTkMxaVltTXpMVEF4WVRkaE5HRTRaRGc0TVNJc0luQmhlV1ZsSWpwN0luQmhjblI1U1dSSmJtWnZJanA3SW5CaGNuUjVTV1JVZVhCbElqb2lUVk5KVTBST0lpd2ljR0Z5ZEhsSlpHVnVkR2xtYVdWeUlqb2lNaUlzSW1aemNFbGtJam9pWkdaemNESWlmWDBzSW5CaGVXVnlJanA3SW5CaGNuUjVTV1JKYm1adklqcDdJbkJoY25SNVNXUlVlWEJsSWpvaVRWTkpVMFJPSWl3aWNHRnlkSGxKWkdWdWRHbG1hV1Z5SWpvaU1TSXNJbVp6Y0Vsa0lqb2laR1p6Y0RFaWZTd2ljR1Z5YzI5dVlXeEpibVp2SWpwN0ltTnZiWEJzWlhoT1lXMWxJanA3SW1acGNuTjBUbUZ0WlNJNklrMWhkSE1pTENKc1lYTjBUbUZ0WlNJNklraGhaMjFoYmlKOUxDSmtZWFJsVDJaQ2FYSjBhQ0k2SWpFNU9ETXRNVEF0TWpVaWZYMHNJbUZ0YjNWdWRDSTZleUpoYlc5MWJuUWlPaUl4TURBd01DSXNJbU4xY25KbGJtTjVJam9pUlZWU0luMHNJblJ5WVc1ellXTjBhVzl1Vkhsd1pTSTZleUp6WTJWdVlYSnBieUk2SWxSU1FVNVRSa1ZTSWl3aWFXNXBkR2xoZEc5eUlqb2lVRUZaUlZJaUxDSnBibWwwYVdGMGIzSlVlWEJsSWpvaVEwOU9VMVZOUlZJaWZYMAA",
    "condition":"T0RK8jVcV4EHIZUhF9Rc_x6lpKkDVr7RSdwsdlgcknw",
    "payeeReceiveAmount":{
        "amount":"16543",
        "currency":"MAD"
    },
    "extensionList":{
        "extension":[{
                "key":"forexRate",
                "value":"1.6543"
        }]
    }
}
```




## Add a new Currency
 
If you want to add a new currency you need to do these tasks

- Add a new rule in quoting service.
- Create a new virtual DFSP. You have to create a new DFSP in the simulator. Go to [simulator](./simulator/src)
  and create a new folder with virtual's and copy the content from other folder like DFSPEUR.
- Onboarding virtual DFSP
- Onboarding new DFSP with new currency.







