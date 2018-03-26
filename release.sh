#!/bin/bash
set -e

if ! [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
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
git checkout $masterBranch || exit 1
git pull origin $masterBranch || exit 1

printf "\n"
echo "Switched to branch $masterBranch and pulled the last version."
printf "\n"

# checkout to release branch, gets its last version and merge master into it to resolve conflicts
git checkout $releaseBranch || exit 1
git pull origin $releaseBranch || exit 1
git merge $masterBranch -m "Merge $masterBranch into $releaseBranch" || exit 1

printf "\n"
echo "Switched to branch $releaseBranch and merged $masterBranch into it"
printf "\n"

# checkout to master and merge release branch into it
git checkout $masterBranch || exit 1
git merge --no-ff $releaseBranch -m "Merge $releaseBranch into $masterBranch" || exit 1

printf "\n"
echo "Switched to branch $masterBranch and merged $releaseBranch into it"
printf "\n"

# create tag for new version from -master
git tag $versionLabel || exit 1
git push --tags || exit 1
git push origin $masterBranch || exit 1

printf "\n"
echo "Created tag $versionLabel into $masterBranch"
printf "\n"

# remove release branch remotely and locally
git push -d origin $releaseBranch || exit 1
git branch -D $releaseBranch || exit 1

printf "\n"
echo "Deleted release $releaseBranch remotely and locally, you're in branch $masterBranch now!"
echo "Congrats on your new release!"

exit 0
