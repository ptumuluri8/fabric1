# Asset Management

## Application Description

## Environment Setup

Please review instructions on setting up the [Development Environment](https://github.com/hyperledger/fabric/blob/master/docs/dev-setup/devenv.md) as well as the setting up the [Sandbox Environment](https://github.com/hyperledger/fabric/blob/master/docs/Setup/Chaincode-setup.md) to execute the chaincode.

## Running the Application

Clone Asset Management application code from github repository (https://github.com/ITPeople-BlockChain4SCM/assetmanagement)**
```
 cd $GOPATH/src/github.com/hyperledger/fabric
 git clone https://github.com/ITPeople-BlockChain4SCM/assetmanagement.git
```
###Terminal 1

Spinup 4 peer and membersrvc network of pre-build docker images on *v0.5-developer-preview* branch using the below script [Peer network setup](https://raw.githubusercontent.com/rameshthoomu/fabric1/tools/localpeersetup/local_fabric_v0.5-developer-preview.sh)
follow below scripts to run spinup peer network

 * curl -L https://raw.githubusercontent.com/rameshthoomu/fabric1/tools/localpeersetup/local_fabric_v0.5-developer-preview.sh -o local_fabric_v0.5-developer-preview.sh
 * chmod +x local_fabric_v0.5-developer-preview.sh
 * ./local_fabric_v0.5-developer-preview.sh -n 4 -s -c cfc2099

###Terminal 2

Copy MQLITE folder into assetmanagement directory and execute below command to subscribe to bluemix msg-hub application
```
 * cd $GOPATH/src/github.com/hyperledger/fabric/assetmanagement
 * npm install mqlight
 * npm install
 * node sendmsg.js
```
the output of the above command will give you below *Connected to https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=4183a4b6-d535-4a5f-8848-49dbbf3245dc using client-id AUTO_038a364*
###Terminal 3

Execute below command to post and update assests in *sendlocation* directory.

```
 cd $GOPATH/src/github.com/hyperledger/fabric/assetmanagement
 ./asset-MQ.sh -u 5
```
Above script takes 5 json files from update folder and send it to *sendlocation* directory. While executing this script, user can refresh bluemix application page to view the updated assets information.

Access Bluemix Application from here: http://asset-mgmt-v10.mybluemix.net/
