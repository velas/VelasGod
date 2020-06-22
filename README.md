# Velas God

This is client/server solution which obtain information from the velas node and sends it to server (god).


Use cases

* Server collects all information and provide for AI/Admins
* TODO: Server notifies node owners by telegram about problems
* TODO: Server decides which node should process the incoming transaction


### Deps

```sh
npm i pm2 livescript -g
```


### Start client

This is client. Need to put it at the same folder as blockchain because it parses config.toml
Also it connects to GOD object of pm2 and trying to extract the running process by 'name'

```sh
lsc client/client.ls --name fake
# or
# cd client && pm2 start churchman.sh
```

### Start server

This is collector service. It receives information from all clients

```sh
lsc server/server.ls
# or
# cd server && pm2 start god.sh
```




### Start fake service (for unit testing)

This is fake blockchain node to produce random logs. Just for testing

```sh 
cd fake
pm2 start fake.sh
```