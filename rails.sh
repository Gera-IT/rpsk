#!/bin/bash

PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR
AP_GEMSET="$PROJECT_NAME"

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

git remote add origin $REPO_URL
git push -u origin master

cd $CURRENT_PATH
printf "\n"
printf "Note: Please configure your staging smtp getaway and other staging vars in $CURRENT_PATH/provisioning/group_vars/staging [Ansible] \n"
