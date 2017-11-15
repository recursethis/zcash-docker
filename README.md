# zcash-docker
Dockerfiles and docker-compose files for zcash on testnet and zcash faucet running locally

# Quick start

```
# deploy zcashd & zcash faucet stack
cd demo/nodeA/
docker-compose pull
docker-compose up -d

# to access zcash client
docker exec -it nodea_zcashd_1 /bin/bash

# generate addresses
root@zcashd:~/.zcash# z getnewaddress 
root@zcashd:~/.zcash# z z_getnewaddress

# list shielded addresses
root@zcashd:~/.zcash# z z_listaddresses

# list transparent addresses
root@zcashd:~/.zcash# z getaddressesbyaccount ""

# sign and verify messages
root@zcashd:~/.zcash# z signmessage "<transparent address>" "<message>"
root@zcashd:~/.zcash# z verifymessage "<transparent address>" "<signature>" "<message>"

# send transaction to shielded address
root@zcashd:~/.zcash# z z_sendmany "<your shielded address>" '[{"address": "<other shielded or transparent address>", "amount": "0.01", "memo": ""}]

# check transaction result
root@zcashd:~/.zcash# z z_getoperationresult '["<operation id>"]'

# send transaction to transparent address
root@zcashd:~/.zcash# z sendtoaddress "<other transparent address>" 0.1 "comment" "comment-to" true

# check transaction result
z gettransaction <transaction id>

# check balance with 0 or 1 confirmations
root@zcashd:~/.zcash# z z_gettotalbalance 0
root@zcashd:~/.zcash# z z_gettotalbalance 1
```
zcash faucet UI available at http://[docker host]:[docker port]/, e.g. http://192.168.99.100:81/
  
# Start your own testnet node
## Directory-structure
* zcash-docker/your_node/
  * docker-compose.yml
  * zcashd/
    * zcashd.conf
    
1. Create zcash.conf file
```
rpcuser=<username>
rpcpassword=<password>
testnet=1
addnode=testnet.z.cash
rpcallowip=<docker network IP>, e.g. 172.23.0.0/16
rpcport=18232
# for mining 
# required if you want to populate your faucet with coins 
# (or use a publicly available faucet)
#gen=1
#proclimit=<N>
````
OR
```
# autogenerates default zcash.conf file
cd zcash-docker/
docker build -t recursethis/zcashd:latest zcashd/
```

2. update docker-compose file
```
version: '2.1'

services:
    # zcash daemon stack #
    zcashd:
        image: recursethis/zcashd:latest
        tty: true
        expose:
            - 18232
            - 8232
        networks:
            - net
        volumes:
            - ${PWD}/zcashd/:/config/
            - zcashd:/root/.zcash/:rw

    # zcash faucet stack #
    nginx:
        image: recursethis/zfaucet-nginx:2.0
        ports:
            - <docker port>:80
        networks:
            - net
        depends_on:
            - faucet
        volumes:
            - faucet_static:/home/zcash/faucet/faucet/static/:ro
            - nginx_log:/var/log/nginx/:rw

    faucet:
        image: recursethis/zfaucet:3.0
        environment:
            - DOCKER_IP=<docker IP>, e.g 192.168.99.100
        healthcheck:
            test: python manage.py sweepfunds && python manage.py healthcheck
            interval: 5m
        expose:
            - 8000
        depends_on:
            - db
        networks:
            - net
        volumes:
            - ${PWD}/zcashd/:/root/.zcash/:ro
            - faucet_static:/home/zcash/faucet/faucet/static/:rw
            
    fail2ban:
        image: recursethis/zfaucet-fail2ban:3.0
        privileged: true
        network_mode: host
        volumes:
            - nginx_log:/var/log/nginx/:rw
            
    db:
        image: postgres:10-alpine
        environment:
            - POSTGRES_PASSWORD=mysecretpassword
            - POSTGRES_USER=django
            - POSTGRES_DB=django
        networks:
            - net

networks:
    net:
        ipam:
            config:
                - subnet: <docker network subnet>, e.g. 172.23.0.0/16
                  gateway: <docker network gateway>, e.g. 172.23.0.1

volumes:
    zcashd:
    faucet_static:
    nginx_log:
```

3. deploy
```
docker-compose pull
docker-compose up -d
```
Note: fail2ban is optional. Can deploy without it, by running 1docker-compose up -d zcashd`, then `docker-compose up -d nginx`
