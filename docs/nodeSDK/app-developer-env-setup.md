# Setting up the Full Hyperledger fabric Developer's Environment

1. See [Setting Up The Development Environment](../dev-setup/devenv.md) to set up your development environment.

2. Issue the following commands to build the Node.js Client SDK including the API reference documentation  

   ```
   cd /opt/gopath/src/github.com/hyperledger/fabric
   make node-sdk
   ```
3. Issue the following commands to set the HFC as a Node.js global package available to your Node.js application with the `require("hfc")`.  

   ```
   cd /opt/gopath/src/github.com/hyperledger/fabric/sdk/node
   sudo npm install --unsafe-perm -g
   ```
   
   You may have to export the location of the global Node packages
   ```
   export NODE_PATH=/usr/local/lib/node_modules
   ```
      
4. To see the API reference documentation which is built when the above `make node-sdk` runs. To view:
   ```
   cd /opt/gopath/src/github.com/hyperledger/fabric/sdk/node/doc
   ```

   The [Self Contained Node.js Environment](node-sdk-self-contained.md) will have the reference documentation already built and may be access by:
   ```
   docker exec -it nodesdk /bin/bash
   cd /opt/gopath/src/github.com/hyperledger/fabric/sdk/node/doc
   ```
