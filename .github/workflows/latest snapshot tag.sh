#!/bin/bash

#  latest snapshot tag.sh
#  neuCKAN
#
#  Created by you on 20-05-13.
#  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.

# get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# use the specified branch if given
while getopts b: option; do
	case "${option}" in
		b) BRANCH=${OPTARG};;
	esac
done

# get all tags, and save them in an array
IFS="\n" read -a TAGS <<< "$(git rev-parse --abbrev-ref --tags)"

# iterate through tags and look for the current branch's latest snapshot
for TAG in "${TAGS[@]}" ;do
	TAGBRANCH=${${TAG#*-}%%-*}
	if [ "$TAGBRANCH" = "$BRANCH" ]; then
		# print out the current branch's latest snapshot
		echo "$TAG"
		exit 0
	fi
done

echo "no snapshot for branch $BRANCH"
