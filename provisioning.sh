#!/bin/bash

PP_NAME="$(echo $PROJECT_NAME)_provisioning"
PP_DIR="$BASE_DIR/$(echo $PP_NAME)"
PP_TEMPLATES_DIR="$CURRENT_PATH/templates/ansible"

printf "Creating $(echo $PP_NAME)...\n"

mkdir -p $PP_DIR
cd $PP_DIR

cp -r $PP_TEMPLATES_DIR/* $PP_DIR
sed -e "s/%STAGE_ADDR%/$STAGE_ADDR/g" $PP_DIR/inventories/staging.template > $PP_DIR/inventories/staging
rm $PP_DIR/inventories/staging.template

sed -e "s/%PUBKEY%/$(cat $PUBKEY_PATH | sed -e 's/\//\\\//g')/g" -e "s/%STAGE_USER%/$STAGE_USER/g" -e "s/%PROJECT_NAME%/$PROJECT_NAME/g" -e "s/%STAGE_ADDR%/$STAGE_ADDR/g" -e "s/%RUBY_VERSION%/$RUBY_VERSION/g" -e "s/%INITIAL_USER%/$INITIAL_USER/g" $PP_DIR/group_vars/staging.template > $PP_DIR/group_vars/staging
rm $PP_DIR/group_vars/staging.template

cd  $PP_DIR
git init
git add .
git commit -qm "initial commit"

printf "$PP_NAME project created...\n"
printf "Please review $PP_DIR/group_vars/staging and change default passwords\n"
