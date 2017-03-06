#!/bin/bash

# Known issues:
# - add mailcatcher to Procfile
# - foreman uses PORT=5000 by default, all templates uses 3000 instead
# - no final git commit
#
# Requested features:
# - bower
# * simplecov
# - rubocop
# - rails_best_practices

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

#
# ####################################
# # Provisioning project setup start #
# ####################################
#

printf "Creating provisioning project...\n"
PP_NAME="provisioning"
PP_DIR="$BASE_DIR/$PP_NAME"

PP_TEMPLATES_DIR="$CURRENT_PATH/templates/ansible"

cp -r $PP_TEMPLATES_DIR $PP_DIR
sed -e "s/%STAGE_ADDR%/$STAGE_ADDR/g" $PP_NAME/inventories/staging.template > $PP_DIR/inventories/staging
rm $PP_DIR/inventories/staging.template

sed -e "s/%PUBKEY%/$(cat $PUBKEY_PATH | sed -e 's/\//\\\//g')/g" -e "s/%STAGE_USER%/$STAGE_USER/g" -e "s/%PROJECT_NAME%/$PROJECT_NAME/g" -e "s/%STAGE_ADDR%/$STAGE_ADDR/g" -e "s/%RUBY_VERSION%/$RUBY_VERSION/g" -e "s/%INITIAL_USER%/$INITIAL_USER/g" $PP_DIR/group_vars/staging.template > $PP_DIR/group_vars/staging
rm $PP_DIR/group_vars/staging.template

cd  $PP_DIR
git init
git add .
git commit -qm "initial commit"

printf "$PP_NAME project created...\n"
printf "Please review $PP_DIR/group_vars/staging and change default passwords\n"

#
# ##################################
# # Provisioning project setup end #
# ##################################
#

#
# ##################################
# # Deployment project setup start #
# ##################################
#

printf "Creating deployment project...\n"

DP_NAME=deploy
DP_DIR="$BASE_DIR/$DP_NAME"
DP_GEMSET="$PROJECT_NAME-deploy"
mkdir -p $DP_DIR

DP_TEMPLATES_DIR="$CURRENT_PATH/templates/capistrano"
cp $DP_TEMPLATES_DIR/Gemfile $DP_DIR
cp $DP_TEMPLATES_DIR/Capfile $DP_DIR
mkdir -p $DP_DIR/config/deploy
sed -e "s/%PROJECT_NAME%/$PROJECT_NAME/g" -e "s/%REPO_URL%/$(echo $REPO_URL | sed -e 's/\//\\\//g')/g" $DP_TEMPLATES_DIR/deploy.rb.template > $DP_DIR/config/deploy.rb
sed -e "s/%PROJECT_NAME%/$PROJECT_NAME/g" -e "s/%STAGE_URL%/$STAGE_URL/g" $DP_TEMPLATES_DIR/staging.rb.template > $DP_DIR/config/deploy/staging.rb

printf "Creating gemset...\n"
cd $DP_DIR
rvm use ruby-$RUBY_VERSION@$DP_GEMSET --ruby-version --create
echo $DP_GEMSET > .ruby-gemset
gem install bundler --no-ri --no-rdoc
bundle

printf "Initializing git repository...\n"
echo '.ruby-gemset' > .gitignore
git init
git add .
git commit -qm 'initial commit'

cd $CURRENT_PATH
printf "$DP_NAME project created...\n"

#
# #################################
# # Deployment project setup end  #
# #################################
#

AP_NAME=app
AP_DIR="$BASE_DIR/$AP_NAME"
mkdir -p $AP_DIR
cd $AP_DIR
AP_GEMSET="$PROJECT_NAME-app"

if [[ -f ".ruby-version" ]] ; then
  printf "Using existing gemset...\n"
else
  printf "Creating gemset...\n"
  rvm use ruby-$RUBY_VERSION@$AP_GEMSET --ruby-version --create
fi

printf "Installing rails...\n"
gem install rails --no-ri --no-rdoc

printf "Installing rails_apps_composer...\n"
gem install rails_apps_composer

if [[ -f $CURRENT_PATH/defaults.yml ]] ; then
  rails_apps_composer new . \
    --recipe_dirs=$CURRENT_PATH/recipes \
    --defaults=$CURRENT_PATH/defaults.yml \
    --quiet \
    --verbose
else
  rails_apps_composer new . \
    --recipe_dirs=$CURRENT_PATH/recipes \
    --quiet \
    --verbose
fi

# TODO for future purposes
# rails_apps_composer template gera.rb \
#   --recipe_dirs=$CURRENT_PATH/recipes \
#   --defaults=$CURRENT_PATH/$DEFAULTS \
#   --quiet \
#   --verbose

#git remote add origin $REPO_URL
#git push -u origin master

cd $CURRENT_PATH
printf "\n"
printf "Note: Please configure your staging smtp getaway and other staging vars in $CURRENT_PATH/provisioning/group_vars/staging [Ansible] \n"
