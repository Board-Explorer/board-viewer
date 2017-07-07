#!/bin/bash

# Get the highest tag number from GIT

VERSION=$(git tag | sort -rV | head -n 1)
CURRENT=${VERSION}

# Strip the v
VERSION=${VERSION:1}
VERSION="${VERSION%.*}.$((${VERSION##*.}+1))"

TAG=${1}
TAG=${TAG:=${VERSION}}

[ "${1}" == "--help" ] && {
cat << EOF

usage: tag-release.sh [major.api.minor]

Example:

./tag-releas.sh 0.0.9

If version string is not provided, the next highest tag is calculated
based on the tags in git, which is '${VERSION}'.

EOF
  exit -1
}


git diff-index --quiet --cached HEAD -- || {
cat << EOF

Staged (not yet committed) changes detected in tree. You must
commit or stash the changes prior to running ./tag-release.sh

EOF
  exit -1
}

git diff-index --quiet --cached "${CURRENT}" -- && {
cat << EOF

There are no changes in the current tree from the last tagged
version ($CURRENT).

EOF
  exit -1
}

echo "Tagging tree as '${TAG}'"
git tag -a v${TAG} -m "${TAG}"
git push --tags

cat << EOF

Done.

You can now publish the project:

  git push origin master
  polymer build
  ./publish.sh

EOF

