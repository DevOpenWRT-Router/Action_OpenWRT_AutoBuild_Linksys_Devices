#!/bin/sh -l
#################################################################
# (C) 2021 By Eliminater74 For OpenWRT
# Updated: 20210822
#
#
#################################################################
#
# To run Simple GITHUB commands and prepare Dir
#
#################################################################
set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable
D="$(date +"%Y.%m.%d-%H%M")"

echo "[+] Action start"
SOURCE_DIRECTORY_A="openwrt/bin/packages/arm_cortex-a9_vfpv3-d16"
SOURCE_DIRECTORY_B="openwrt/bin/targets/mvebu/cortexa9/kmods/$KMOD_DIR"
DESTINATION_GITHUB_USERNAME="DevOpenWRT-Router"
DESTINATION_REPOSITORY_NAME="Linksys_OpenWRT_Releases"
USER_EMAIL="BuildBot2021@gmail.com"
USER_NAME="BuildBot2021"
DESTINATION_REPOSITORY_USERNAME="DevOpenWRT-Router"
TARGET_BRANCH="main"
COMMIT_MESSAGE="Updated: $D"
TARGET_DIRECTORY_A="packages"
TARGET_DIRECTORY_B="kmods/$KMOD_DIR"

if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
then
  DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
fi

if [ -z "$USER_NAME" ]
then
  USER_NAME="$DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)
echo "[+] Created CLONE_DIR: $CLONE_DIR"

echo "[+] Cloning destination git repository $DESTINATION_REPOSITORY_NAME"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TEMP_DIR=$(mktemp -d)
echo "[+] Created TEMP_DIR: $TEMP_DIR"
# This mv has been the easier way to be able to remove files that were there
# but not anymore. Otherwise we had to remove the files from "$CLONE_DIR",
# including "." and with the exception of ".git/"
echo "[+] Moving $CLONE_DIR/.git into $TEMP_DIR/.git"
mv "$CLONE_DIR/.git" "$TEMP_DIR/.git"

### ------------------------------------------------------------ ###

echo "[+] Checking if $TARGET_DIRECTORY_A exist in git repo $DESTINATION_REPOSITORY_NAME"
# Remove contents of target directory and create a new empty one
if [ -d "$CLONE_DIR/$TARGET_DIRECTORY_A/" ]
then
echo "[+] Deleting files from $TARGET_DIRECTORY_A in git repo $DESTINATION_REPOSITORY_NAME"
rm -R "${CLONE_DIR:?}/$TARGET_DIRECTORY_A/"
fi
echo "[+] Creating $TARGET_DIRECTORY_A if doesnt already exist"
mkdir -p "$CLONE_DIR/$TARGET_DIRECTORY_A"

### ------------------------------------------------------------ ###

echo "[+] Checking if $TARGET_DIRECTORY_B exist in git repo $DESTINATION_REPOSITORY_NAME"
# Remove contents of target directory and create a new empty one
if [ -d "$CLONE_DIR/$TARGET_DIRECTORY_B/" ]
then
echo "[+] Deleting files from $TARGET_DIRECTORY_B in git repo $DESTINATION_REPOSITORY_NAME"
rm -R "${CLONE_DIR:?}/$TARGET_DIRECTORY_B/"
fi
echo "[+] Creating $TARGET_DIRECTORY_B if doesnt already exist"
mkdir -p "$CLONE_DIR/$TARGET_DIRECTORY_B"

### ------------------------------------------------------------ ###

echo "[+] Listing New Created Directory Names"
ls -al "$CLONE_DIR"

echo "[+] Moving $TEMP_DIR/.git into $CLONE_DIR/.git"
mv "$TEMP_DIR/.git" "$CLONE_DIR/.git"

echo "[+] Checking if local $SOURCE_DIRECTORY_A exist"
if [ ! -d "$SOURCE_DIRECTORY_A" ]
then
	echo "ERROR: $SOURCE_DIRECTORY_A does not exist"
	echo "This directory needs to exist when push-to-another-repository is executed"
	echo
	echo "In the example it is created by ./build.sh: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19"
	echo
	echo "If you want to copy a directory that exist in the source repository"
	echo "to the target repository: you need to clone the source repository"
	echo "in a previous step in the same build section. For example using"
	echo "actions/checkout@v2. See: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L16"
	exit 1
else
echo "[+] The local directory $SOURCE_DIRECTORY_A does exist"
fi

### ------------------------------------------------------------ ###

echo "[+] Checking if local $SOURCE_DIRECTORY_B exist"
if [ ! -d "$SOURCE_DIRECTORY_B" ]
then
	echo "ERROR: $SOURCE_DIRECTORY_B does not exist"
	echo "This directory needs to exist when push-to-another-repository is executed"
	echo
	echo "In the example it is created by ./build.sh: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19"
	echo
	echo "If you want to copy a directory that exist in the source repository"
	echo "to the target repository: you need to clone the source repository"
	echo "in a previous step in the same build section. For example using"
	echo "actions/checkout@v2. See: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L16"
	exit 1
else
  echo "[+] The local directory $SOURCE_DIRECTORY_B does exist"
fi

### ------------------------------------------------------------ ###

echo "[+] Copying contents of source repository folder $SOURCE_DIRECTORY_A to folder $TARGET_DIRECTORY_A in git repo $DESTINATION_REPOSITORY_NAME"
cp -ra "$SOURCE_DIRECTORY_A"/. "$CLONE_DIR/$TARGET_DIRECTORY_A"

echo "[+] Copying contents of source repository folder $SOURCE_DIRECTORY_B to folder $TARGET_DIRECTORY_B in git repo $DESTINATION_REPOSITORY_NAME"
cp -ra "$SOURCE_DIRECTORY_B"/. "$CLONE_DIR/$TARGET_DIRECTORY_B"

echo "[+] CD $CLONE_DIR"
cd "$CLONE_DIR"

echo "[+] Files that will be pushed"
ls -la

ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"

echo "[+] Files Pushed successfully"

echo "[+] Find your Files Here: https://github.com/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"

exit 0
