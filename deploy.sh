#!/bin/bash

DP_NAME="$(echo $PROJECT_NAME)_deploy"
DP_DIR="$BASE_DIR/$(echo $PROJECT_NAME)_deploy"

printf "Creating $(echo $PROJECT_NAME)...\n"

DP_GEMSET="$PROJECT_NAME_deploy"
mkdir -p $DP_DIR
cd $DP_DIR

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
git remote add origin $CAPISTRANO_REPO_URL
git push -u origin master

printf "$DP_NAME project created...\n"
