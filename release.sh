#!/bin/bash
set -e

if ! [[ $2 =~ ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$ ]] 
then
    echo "Version number must be in x.y.z format" >&2
    exit 1
fi

# branch with the code which will be released
releaseBranch=$1

# v1.0.0, v1.5.2, etc.
versionLabel=v$2

# establish branch and tag name variables
masterBranch=master

# checkout to master and gets its last version
git checkout $masterBranch 

git pull origin 

printf "\n"
echo "Got $masterBranch last version."
printf "\n"

# checkout to release branch, gets its last version and merge master into it to resolve conflicts
git checkout $releaseBranch

git pull origin

git merge $masterBranch

printf "\n"
echo "Merged $masterBranch into $releaseBranch"
printf "\n"

# checkout to master and merge release branch into it
git checkout $masterBranch

git merge --no-ff $releaseBranch

printf "\n"
echo "Merged release $releaseBranch into $masterBranch"
printf "\n"

# create tag for new version from -master
git tag $versionLabel
git push --tags

printf "\n"
echo "Created tag $versionLabel into $masterBranch"
printf "\n"

# remove release branch remotely and locally
git push -d origin $releaseBranch

git branch -D $releaseBranch

printf "\n"
echo "Deleted release $releaseBranch remotely and locally"
echo "Congrats on your new release!"
