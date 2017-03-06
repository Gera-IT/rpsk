#!/bin/bash

LOCAL_RVM_PATH="$HOME/.rvm/scripts/rvm"
GLOBAL_RVM_PATH="/usr/local/rvm/scripts/rvm"
CURRENT_PATH=`pwd`

# Load RVM into a shell session *as a function*
if [[ -s $LOCAL_RVM_PATH ]] ; then
  # First try to load from a user install
  source $LOCAL_RVM_PATH
elif [[ -s $GLOBAL_RVM_PATH ]] ; then
  # Then try to load from a root install
  source $GLOBAL_RVM_PATH
else
  printf "ERROR: An RVM installation was not found. You must install RVM first.\n"
  exit 1
fi

read -p "Please provide base dir for project [$HOME/Projects] " BASE_DIR
BASE_DIR=${BASE_DIR:-$HOME/Projects}

read -p "Please provide project name [myapp]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-myapp}

read -p "Please provide ruby version [2.4.0]: " RUBY_VERSION
RUBY_VERSION=${RUBY_VERSION:-2.4.0}

read -p "Please provide staging server address: [$PROJECT_NAME.your-domain.com] " STAGE_ADDR
STAGE_ADDR=${STAGE_ADDR:-$PROJECT_NAME.your-domain.com}

read -p "Please provide staging server application user: [$PROJECT_NAME] " STAGE_USER
STAGE_USER=${STAGE_USER:-$PROJECT_NAME}

read -p "Please provide initial provisioning user name: [root] " INITIAL_USER
INITIAL_USER=${INITIAL_USER:-root}

read -p "Please provide git repository address: [git@github.com:some_github_user/$PROJECT_NAME.git] " REPO_URL
REPO_URL=${REPO_URL:-git@github.com:some_github_user/$PROJECT_NAME.git}

STAGE_URL="$STAGE_USER@$STAGE_ADDR"

read -p "Please provide path to your public key: [$HOME/.ssh/id_rsa.pub] " PUBKEY_PATH
PUBKEY_PATH=${PUBKEY_PATH:-$HOME/.ssh/id_rsa.pub}

#
# #######################
# # Prerequisites start #
# #######################
#

BASE_DIR="$BASE_DIR/$PROJECT_NAME"
mkdir -p $BASE_DIR
cd $BASE_DIR

rvm install $RUBY_VERSION

#
# #####################
# # Prerequisites end #
# #####################
#