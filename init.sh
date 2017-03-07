#!/bin/bash

ask() {
    # http://djm.me/ask
    local prompt default REPLY

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

LOCAL_RVM_PATH="$HOME/.rvm/scripts/rvm"
GLOBAL_RVM_PATH="/usr/local/rvm/scripts/rvm"
CURRENT_PATH=`pwd`
VAGRANT_IP="192.168.33.11"

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

cat << EndOfMessage
We created this nice tool for YOU!

What we have? Look at this list:
1. Creation Rails Application
2. Creation Capistrano application for easy deployment
3. Creation Ansible application for provision new server

What we want from you?
1. Create new repository for your rails application (You can use GitHub or Gitlab or another git service)
2. Create new repository for your capistrano application (I prefer a Gitlab)
3. Create new repository for your ansible application (I prefer a Gitlab)

Are you ready? Let's GO.
EndOfMessage

if ask "Do you want to install Rails Application?" Y; then
  INSTALL_RAILS_APPLICATION=1
else
  INSTALL_RAILS_APPLICATION=0
fi

if ask "Do you want to install Capistrano?" Y; then
  INSTALL_CAPISTRANO=1
else
  INSTALL_CAPISTRANO=0
fi

if ask "Do you want to install Ansible?" Y; then
  INSTALL_ANSIBLE=1
else
  INSTALL_ANSIBLE=0
fi

read -p "Please provide base dir for project [$HOME/Projects] " BASE_DIR
BASE_DIR=${BASE_DIR:-$HOME/Projects}

read -p "Please provide project name [myapp]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-myapp}

read -p "Please provide ruby version [2.4.0]: " RUBY_VERSION
RUBY_VERSION=${RUBY_VERSION:-2.4.0}

read -p "Please provide staging server address: [$PROJECT_NAME.your-domain.com] " STAGE_ADDR
STAGE_ADDR=${STAGE_ADDR:-$VAGRANT_IP}

read -p "Please provide staging server application user: [$PROJECT_NAME] " STAGE_USER
STAGE_USER=${STAGE_USER:-$PROJECT_NAME}

read -p "Please provide initial provisioning user name: [root] " INITIAL_USER
INITIAL_USER=${INITIAL_USER:-root}

if [[ $INSTALL_RAILS_APPLICATION = 1 ]]; then
  read -p "Please provide git repository address for Rails Application: [git@github.com:some_github_user/$PROJECT_NAME.git] " REPO_URL
  REPO_URL=${REPO_URL:-git@github.com:some_github_user/$PROJECT_NAME.git}
fi

if [[ $INSTALL_CAPISTRANO = 1 ]]; then
  read -p "Please provide git repository address for Capistrano Application: [git@github.com:some_github_user/$PROJECT_NAME.git] " CAPISTRANO_REPO_URL
  CAPISTRANO_REPO_URL=${CAPISTRANO_REPO_URL:-git@github.com:some_github_user/$PROJECT_NAME.git}
fi

if [[ $INSTALL_ANSIBLE = 1 ]]; then
  read -p "Please provide git repository address for Ansible Application: [git@github.com:some_github_user/$PROJECT_NAME.git] " ANSIBLE_REPO_URL
  ANSIBLE_REPO_URL=${ANSIBLE_REPO_URL:-git@github.com:some_github_user/$PROJECT_NAME.git}
fi

STAGE_URL="$STAGE_USER@$STAGE_ADDR"

read -p "Please provide path to your public key: [$HOME/.ssh/id_rsa.pub] " PUBKEY_PATH
PUBKEY_PATH=${PUBKEY_PATH:-$HOME/.ssh/id_rsa.pub}

rvm install $RUBY_VERSION

if [[ $INSTALL_RAILS_APPLICATION = 1 ]]; then
  source "$CURRENT_PATH/rails.sh"
fi

if [[ $INSTALL_CAPISTRANO = 1 ]]; then
  source "$CURRENT_PATH/deploy.sh"
fi

if [[ $INSTALL_ANSIBLE = 1 ]]; then
  source "$CURRENT_PATH/provisioning.sh"
fi
