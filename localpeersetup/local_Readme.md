# Spinup Local Peer Network

The purpose of this script is to spinup peers in local machine using docker. Script launches peers in docker containers and uses approved peer, membersrvc and latest hyperledger/fabric base image pulls from rameshthoomu docker hub account. Look for the commits pushed to docker hub account. (https://hub.docker.com/u/hyperledger/)

Before execute local_fabric.sh script in your system, make sure your system satisfies the below requirements.

1. Install docker [Docker installation in ubuntu](https://docs.docker.com/engine/installation/linux/ubuntulinux/) and run docker service.

2. If applicable, verify ufw firewall status in non-vagrant environment. Disable firewall if it is enabled.

  - `sudo ufw status`
  - `sudo ufw disable`

3. Clear `iptables` rules (if firewall rules are rejecting docker requests) and re-start docker daemon.

  - `iptables -L` //(to view iptable rules)
  - `iptables -D INPUT 4` //ex: to delete Reject rules from INPUT policy. 4 is the row number to delete)

4. If appicable, build peer and membersrvc images in your local machine using makefile and provide the image name and commit number to local_fabric script otherwise take the commit number from above mentioned docker hub account.

  Move to directory where the makefile is located (root of the fabric directory) 

  - `cd $GOPATH/src/github.com/hyperledger/fabric`
  - `make images`
  - `docker tag <imagename>:<tagname> <newimagename>:<newtagname>` //usually newtagname will be a commit number

###Pulling Docker Images:

Fabric script automatically pulls specified commits of hyperledger/fabric-peer and hyperledger/fabric-membersrvc from Docker Hub (Please check the commit number associated to the latest tag in hyperledger/fabric-peer and hyperledger/fabric-membersrvc docker hub). [Docker Hub Account](https://hub.docker.com/u/hyperledger/)

###Spinup peers in local network:

Use below script to spinup peers on gerrit code base:

curl [local_fabric.sh](https://raw.githubusercontent.com/rameshthoomu/fabric1/tools/localpeersetup/local_fabric.sh) file into local machine and follow below instructions to run the script.

Use below script to spinup peers on github v0.5 code base:

curl [local_fabric_v0.5-developer-preview.sh](https://raw.githubusercontent.com/rameshthoomu/fabric1/tools/localpeersetup/local_fabric_v0.5-developer-preview.sh) file into local machine and follow below instructions to run the script.

Example:

`curl -L https://raw.githubusercontent.com/rameshthoomu/fabric/tools/localpeersetup/local_fabric.sh -o local_fabric.sh`

####Follow below steps:

  - chmod +x local_fabric.sh 
  - dos2unix ./local_fabric.sh //to make sure file is good to execute in unix environment.
  - ./local_fabric.sh -n 4 -s -c x86_64-0.6.0-SNAPSHOT-f3c9a45 -l debug -m pbft // commit message format is different in both gerrit and github. For github commit tags, please click [rameshthoomu Docker hub account](https://hub.docker.com/r/rameshthoomu/) and check here [Hyperledger Docker hub account](https://hub.docker.com/u/hyperledger/) for gerrit commit tags.

####USAGE:
```
./local_fabric.sh -n <number of peers> -s <enable security and Privacy> -c <Specific Commit> -l <Enable Logging method> -m <Consensus Mode>

OPTIONS:

-h/? - Print a usage message
-n   - Number of peers to launch
-s   - Enable Security and Privacy
-c   - Provide Specific peer and membersrvc docker image commit
-l   - Enable logging method
-m   - Enable consensus mode
 Example: 
./local_fabric.sh -n 4 -s -c x86_64-0.6.0-SNAPSHOT-f3c9a45 -l debug -m pbft
```

![4 peer network](peers.png)

###Useful Docker Commands:

1. Kill all containers
  - `docker rm $(docker kill $(docker ps -aq))` (user rm -f to force kill)
2. Remove all exited containers
  - `docker ps -aq -f status=exited | xargs docker rm`
3. Remove all Images except 'openblockchain/baseimage'
  - `docker rmi $(docker images | grep -v 'hyperledger/fabric-baseimage:latest' | awk {'print $3'})`
4. Stop Docker container
  - `docker stop <Container ID>`
5. Start Docker container
  - `docker start <Container ID>`
6. To know running containers
  - `docker ps`
7. To know all containers (Including active and non-active)
  - `docker ps -a`
9. To view NetworkSettings of a Container
  - `docker inspect <Container ID>`
10. To View Logs of a Container
  - `docker logs -f <Container ID>`

## Testing Chaincode in CLI mode:

Execute below command to get into PEER0 docker container `docker exec -it PEER0 bash` and execute below commands to Register an user, Deploy chaincode, Invoke transaction and Query transaction commands from container CLI.

### Registering user inside PEER0 container:

`peer network login test_user0` or `peer network login test_user0 -p MS9qrN8hFjlE`

```
root@7efbae933829:/opt/gopath/src/github.com/hyperledger/fabric# peer network login test_user0
2016/07/23 00:51:09 Load docker HostConfig: %+v &{[] [] []  [] false map[] [] false [] [] [] [] host    { 0} [] { map[]} false []  0 0 0 false 0    0 0 0 []}
00:51:09.492 [crypto] main -> INFO 002 Log level recognized 'info', set to INFO
00:51:09.493 [main] networkLogin -> INFO 003 CLI client login...
00:51:09.493 [main] networkLogin -> INFO 004 Local data store for client loginToken: /var/hyperledger/production/client/
Enter password for user 'test_user0': ************
00:51:14.863 [main] networkLogin -> INFO 005 Logging in user 'test_user0' on CLI interface...
00:51:15.374 [main] networkLogin -> INFO 006 Storing login token for user 'test_user0'.
00:51:15.374 [main] networkLogin -> INFO 007 Login successful for user 'test_user0'.
00:51:15.374 [main] main -> INFO 008 Exiting.....
```

### Deploy Chaincode inside Peer0 container:
Once user is registered, execute the below command to deploy chaincode on PEER0. Below command is to deploy chaincode on PEER0 when peer is running with Security enabled.

```
peer chaincode deploy -u test_user0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Function":"init", "Args": ["a","100", "b", "200"]}'

```
Chaincode ID creates after successful deploy and displays as output of the above command.
```
root@7efbae933829:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode deploy -u test_user0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Function":"init", "Args": ["a","100", "b", "200"]}'

2016/07/23 00:51:44 Load docker HostConfig: %+v &{[] [] []  [] false map[] [] false [] [] [] [] host    { 0} [] { map[]} false []  0 0 0 false 0    0 0 0 []}
00:51:44.627 [crypto] main -> INFO 002 Log level recognized 'info', set to INFO
a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb
```

### Invoke Chaincode inside Container:

Submit Invoke transaction using the above chaincode ID:

(a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb)

```
peer chaincode invoke -u test_user0 -n a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb -c '{"Function": "invoke", "Args": ["a", "b", "10"]}'
```

Example:

```
root@7efbae933829:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode invoke -u test_user0 -n a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb -c '{"Function": "invoke", "Args": ["a", "b", "10"]}'
2016/07/23 00:55:30 Load docker HostConfig: %+v &{[] [] []  [] false map[] [] false [] [] [] [] host    { 0} [] { map[]} false []  0 0 0 false 0    0 0 0 []}
00:55:30.011 [crypto] main -> INFO 002 Log level recognized 'info', set to INFO
4532e63a-4ba4-40fa-89e7-d9985e2510c4
```

### Query Chaincode inside Container:

Submit Query Transaction using chaincode

```
peer chaincode query -n a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb -c '{"Function": "query", "Args": ["a"]}'
```

Example:

```
root@7efbae933829:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode query -u test_user0 -n a5389f7dfb9efae379900a41db1503fea2199fe400272b61ac5fe7bd0c6b97cf10ce3aa8dd00cd7626ce02f18accc7e5f2059dae6eb0786838042958352b89fb -c '{"Function": "query", "Args": ["a"]}'
2016/07/23 00:52:29 Load docker HostConfig: %+v &{[] [] []  [] false map[] [] false [] [] [] [] host    { 0} [] { map[]} false []  0 0 0 false 0    0 0 0 []}
00:52:29.035 [crypto] main -> INFO 002 Log level recognized 'info', set to INFO
100
```
## Use Case: Modify existing configuration settings of core.yaml in peer docker image:

### 1. Pull images from DockerHub

First, pull latest peer and membersrvc images or pull specific commit docker images from [Docker Hub](https://hub.docker.com/u/hyperledger/)

```
  docker pull hyperledger/fabric-peer:latest
  docker pull hyperledger/fabric-membersrvc:latest
```

Once the images are pulled from dockerhub, follow below process to modify configuration files of peer image.

List out all the docker images available in your system:

`docker images`

```
hyperledger/fabric-peer 3e0e80a             895b42b528a6        3 days ago          1.447 GB
```

### 2. Run Docker Image

Specify the ImageID or Imagename from the output of the above command

`docker run -it <imageID> or <image name> bash`

ex: `docker run -it rameshthoomu/peer bash` or `docker run -it 895b42b528a6 bash`

### 3. Saving changes inside Container

Above command takes you to the container, modify any file inside container ex: `core.yaml` file and press `CTRL + P + Q`. In docker, CTRL + P + Q runs the container in background mode or detached mode and automatically exit from the container.

Execute `docker ps` command to see the container running in detached mode. Take the container ID or container name and execute the below command

`docker commit <ContainerID> <NewImageName>`

Keep the above new Imagename in local_fabric.sh script and execute the script.
