Continuous Integration with Jenkins on Hyperledger/fabric Repository:

* We have implemented CI using Jenkins tool on hyperledger fabric repository. What made us to take this decesion to implement Jenkins on Fabric.

Considering all the limitations observed on Travis we decided to use Jenkins open source tool. Below is the process we have implemented:

We have implemented Continuous Integration using jenkins in a very prominent way.. We have used command line JJB (Jenkins Job Builder) tool of Jenkins to create job definations and job templates. Below is the the way we have created Jenkins job definations and templates.

Following Events have been implemented in Jenkins:

-- When ever a "Patchset created" event is triggerd in "Gerrit" 
-- When ever a "Merged created" event is triggered in "Gerrit"

in the above two cases, Jenkins triggers jenkins jobs and executes below tests:

- Make linter
- Make unit-tests (Go unit-tests)
- Make node-sdk-unit-tests (Node-sdk tests)
- Make behave (functional tests)

once the above tests are executed successfully, we build "Peer" and "Membersrvc" docker images to "Hyperledger docker hub account" and submit voting +1 (upon successful execution) -1 (upon failed build) to patch set in gerrit.

#Envionment we use:

We have created an repository in gerrit to control Jenkins job configuration. As a developer, I clone "ci-management" repository into my local machine, update and push my changes to "ci-management" repository.

We spinup Openstack VM's for each build and supports maximum of 10 builds concunrrently. Each VM runs on Ubuntu14.04 (non-vagrant) environment.



