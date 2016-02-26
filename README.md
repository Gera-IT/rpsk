What is it
==========

**_RPSK_ = rails project starter kit**

This tool is created to simplify the process of creating and deploying rails application.

It generates 3 tools:

- rails application itself (prepared by [rails\_apps\_composer](https://github.com/RailsApps/rails_apps_composer))
- deploy project (capistrano 3 based)
- provisioning project (ansible-based).

**Rails application** includes:

- devise with basic UI and sign in/sign up functonality
- rubocop with [preconfigured config](https://github.com/Gera-IT/gerait_rubocop_config)
- some other usefull tools.

Note: All gems will be of last available version.

**Capistrano project** uses capistrano 3 and is preconfigured to deploy application to provisioned server, defined by ansible scripts.

**Ansible-based provisioning tool** includes:

- required users (`chef` sudoer and application user)
- rvm
- postgresql
- nginx
- monit with web interface accessible at `http://staging-host-FQDN/monit/`
- munin with web interface accessible at `http://staging-host-FQDN/munin/`
- configuration files required by application

All packages will be installed from apt repos at latest version available there.

See how it works
================

[![Rails SDK](http://img.youtube.com/vi/yvJQa9T5_d0/0.jpg)](http://www.youtube.com/watch?v=y99vbWThyx8)

Requirements
============

General:

- [RVM](http://rvm.io/)

Required to run provisioning scripts:

- [Ansible](http://docs.ansible.com/ansible/intro_installation.html)
- rvm_io.rvm1-ruby ansible playbook `ansible-galaxy install rvm_io.rvm1-ruby`
- 'Blank'-state Ubuntu host with FQDN assigned

Usage
=====

To generate a new application it's necessary to simply run `./init.sh`

You will be asked to enter:

1. `base dir for project` - It's a directory on your machine, where generated project directories will be put
2. `project name` - Just a name for you project
3. `ruby version` - No need to explain
4. `staging server address` - FQDN of staging host, address on which your application will be accessible
5. `staging server application user` - User who will be in charge of running your application on staging host
6. `initial provisioning user name` - User who has root/sudo access to your 'blank' state host. Usually `root` for Linode, Digitalocean, `vagrant` for vagrant boxes
7. `git repository address` - Git repository address which capistrano will try to deploy from

After generation is completed, review `group_vars/staging.yml` file from `provisioning` directory and change default passwords

To provision staging host, from `provisioning` directory, run `./initial.sh` to prepare staging host for provisioning, then `./provision.sh` to perform provisioning.

The last one, you need to deploy your application using capistrano project. After deployment it will be running at `http://staging-host-FQDN/`

Tips
====

- Provisioning directory includes `Vagrantfile` with two virtual machines, one with Ansible installed, second in 'blank' state, to try provisioning on virtual machine before going live.
- Keep provisioning. Keep provisioning scripts up-to-date with your application's requirements.
- By default your deploy user does not have sudoer rights. If you need install something or change some system configs there are 2 ways to do this:
    - Login using `chef` user, install\change whatever you need.
    - Login using `chef` user, grant your deploy user sudoer rights, switch back and do whatever you need
- Pull-requests are appreciated
