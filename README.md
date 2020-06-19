# Velas Monitoring


### Start fake service 

This is fake blockchain node to produce random logs. Just for testing

```sh 
pm2 start fake/fake.sh
```

### Start client

This is client. Need to put it at the same folder as blockchain because it parses config.toml
Also it connects to GOD object of pm2 and trying to extract the running process by 'name'

```sh
lsc client/client.ls --name fake
```

### Start server

This is collector service. It receives information from all clients

```sh
lsc server/server.ls
```