# GIT Introduction

Git is a version control system same as svn, cvs.. What is version Control system? 

When developers are creating something (an application, for example), they are making constant changes to the code and releasing new versions, up to and after the first official (non-beta) release.

Install Git client to work on local machine and publish changes to github (remote repository)

    ```
    sudo apt-get update
    sudo apt-get install git
    ```
## Git Workflow
After you install git client in your local machine, first step is to fork origin repository from github.


###Delete Remote Branch:
`git push upstream :<branchName>` or `git push upstream --delete <branchName>`

###Delete Local Branch:
`git branch -D <branchName>`

###View just remote-tracking branches
```
git branch --remotes
git branch -r
```

###View both strictly local as well as remote-tracking branches
```
git branch --all
git branch -a
```
###Delete all the remote branch which are not exited in local

```git push --prune origin``` <<Double check remote name>>

###Rename git branch

```
git branch -m <oldName> <newName>```
git push upstream :oldname < Deletes old branch from remote>
git push --set-upstream origin newName <new local to track a new remote branch>
```

###Sync Remote Rep with local and push changes to remote repo
```
git remote add upstream https://github.com/rameshthoomu/fabric.git
git fetch upstream
git merge upstream/master
git push upstream master
```
###Changing remote url's
```
git remote -v
$ git remote -v
origin  https://github.com/hyperledger/fabric.git (fetch)
origin  https://github.com/hyperledger/fabric.git (push)
upstream        https://github.com/rameshthoomu/fabric.git (fetch)
upstream        https://github.com/rameshthoomu/fabric.git (push)
git remote set-url upstream https://github.com/rameshthoomu79/fabric.git <new url>
upstream        https://github.com/rameshthoomu79/fabric.git (fetch)
upstream        https://github.com/rameshthoomu79/fabric.git (push)
```
