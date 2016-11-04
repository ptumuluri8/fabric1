## Continuous Integration: What is Continuous Integration, and how is it done using Travis and Github?

Travis CI is a free Continuous Integration tool for open-source projects.The Travis CI process what we have implemented on hyperledger/fabric Git Hub repository is the process of automatically building and running tests whenever a change is committed in git hub repository. This is a game changer for us as fabric doesn't have CI process before this and usually it takes time for developer to fetch the committed change and perform tests manually. 

#### How does Travis works on Fabric?

Travis sets up “web-hooks” with Git Hub to automatically run tests. By default, these are set up to run after a pull request is created or when code is pushed up to Git Hub. Travis CI runs every build in x86_64 ubuntu VM's and discard the VM once the build is completed.  We took this initiative and started preparing travis yml file to achieve this. It's a challenging task to setup continuous integration for fabric with Go, Python and docker applications. But, travis setup made our life easy and I have come up with .travis.yml file where I have provided configuration setup instructions to Travis yaml file to install all required software’s like docker, python, pip, behave, grpcio packages, rocksdb and npm.

For every change triggered in Travis is then trigger a VM in could and installs all the software’s mentioned in “before_install” and “Install” sections in .travis.yml file and then executes unit and functional test cases. Integrated slack to send build status notifications to slack channel. I really impressed with Travis features and I have implemented below features. 
- Easy integration (less than a min time) with **GITHUB** (Version control system) and **SLACK** (Notification application).
- CI SKIP (Skip the build with a commit message).
- Deploy build artifacts to Amazon S3.
- Publish Docker Images to docker hub once the build is successful.

#### Few limitations in Travis made us to move to Jenkins: What are they? Interesting to know:

- The major problem what we observed with this approach is installation process takes huge time for every build. This increased fabric build time little more as Travis doesn't support caching mechanism for trusty builds. (Source code of hyperledger fabric is maintaining in public git hub repository).

   - Deploy artifacts doesn't work for Pull Requests due to expose in security keys.
   - Doesn't support builds on S390x OS.
   - Doesn't support Gerrit tool. (Web based code review tool)

Considering above all limitations, we are decided to setup *Jenkins* as CI tool for fabric repository. After  couple of months experience on Travis, it's a challenging task for me to setup Jenkins and we have implemented this in a nice way using *Jenkins Job Builder*. We keep Jenkins configuration in JJB's and maintain this in a *Gerrit* repository.

# Continuous Integration with Jenkins on Hyperledger/fabric Repository:

We are excited to share our experience on setting up Continous Integration on Hyperledger Fabric Repository.

We have implemented CI using Jenkins tool on hyperledger fabric repository. What made us to take this decesion to implement Jenkins on Fabric.

Considering all the limitations observed on Travis we decided to use Jenkins open source tool. Below is the process we have implemented:

We have implemented Continuous Integration using jenkins in a very prominent way.. We have used command line JJB (Jenkins Job Builder) tool of Jenkins to create job definations and job templates. Below is the the way we have created Jenkins job definations and templates.

Following Events have been implemented in Jenkins:

    When ever a "Patchset created" event is triggerd in "Gerrit"
    When ever a "Merged created" event is triggered in "Gerrit"

in the above two cases, Jenkins triggers jenkins jobs and executes below tests:

    Make linter
    Make unit-tests (Go unit-tests)
    Make node-sdk-unit-tests (Node-sdk tests)
    Make behave (functional tests)

once the above tests are executed successfully, we build "Peer" and "Membersrvc" docker images to "Hyperledger docker hub account" and submit voting +1 (upon successful execution) -1 (upon failed build) to patch set in gerrit.
Envionment we use:

We have created an repository in gerrit to control Jenkins job configuration. As a developer, I clone "ci-management" repository into my local machine, update and push my changes to "ci-management" repository.

We spinup Openstack VM's for each build and supports maximum of 10 builds concunrrently. Each VM runs on Ubuntu14.04 (non-vagrant) environment.

Best Practises:
