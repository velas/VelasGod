# Velas Monitoring


### Start fake service 

```sh 
pm2 start fake/fake.sh
```

### Start client

```sh
lsc client/client.ls --name fake
```

### Start server

```sh
lsc server/server.ls
```