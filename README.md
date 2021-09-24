# _NOTE_

# Deprecation Notice
- This repository is deprecated and not maintained by IATI

# Deployment

A repository for managing deployment processes. Single-purpose successor to https://github.com/IATI/IATI-Websites

Current playbooks:
  - `configure_ssh_keys.yml`
      This playbook configures the public SSH keys for all IATI webservers

  - `datastore_dev.yml`
      This playbook deploys the dev Datastore with an updated Ubuntu OS and Apache configuration. Work is ongoing to push these improvements to production, but currently only dev and staging have these updates until we can migrate all products from the live Datastore server.

### Set-up

We recommend you use Python 3.5+ and familiarise yourself with Ansible best practices http://docs.ansible.com/ansible/latest/playbooks_best_practices.html

Ansible 2.4 is a minimum requirement due to the use of the `include_tasks` syntax.

The Datastore and wagtail playbooks have only been tested on Ubuntu 16.04.3 x64 for our internal use. Compatibility with other systems is not guaranteed.

Ansible uses an inventory file to determine what hosts to work against. The inventory file we use is `servers.ini`.

```
# Ping a server
ansible all -i servers.ini -m ping -u root

# Remotely execute code
ansible all -i servers.ini -m command -u root -a "uptime"

# Execute a playbook
ansible-playbook path/to/playbook.yml -i servers.ini
```

#### No SSH key added yet?

Use the `-k` flag to prompt for an SSH password. This will typically be required the first time you login - for example:

```
ansible-playbook path/to/playbook.yml -i servers.ini -u root -k
```

#### Want to add a SSH key?

Notice! This feature is currently unstable and requires some changes which are in progress.

```
ansible-playbook configure.yml -i servers.ini
```

### Important information

#### Using the Postgres Backup roles

We created this backup structure upon recognising that backup needs vary depending on project requirements. We wanted a reusable yet customisable solution and so created this process.

To use the `postgres_backup_cron` role in `common/postgres` you will need to do the following:

- Create a template file named `postgres_backup.sh.j2` in the `templates` directory of the role which includes `postgres_backup_cron`.
- Use this template to specify the specific backup requirements for your project. For example, the IATI website project needs to package media files with its encrypted `pg_dump`, whereas backing up the Datastore does not require this.
- Ensure you have created and specified the values of your `cron` scheduling variables.
- Ensure you have created and specified the values of any other variables you have used in your `postgres_backup.sh.j2` template.

To use the `postgres_setup_recovery` role in `common/postgres` you will need to do the following:

- Create a template file named `postgres_recover_backup.sh.j2` in the `templates` directory of the role which includes `postgres_setup_recovery`.
- Use this template to specify the backup recovery process for your project. For example, the IATI website project unpacks a gzipped file from S3, erases the current database, decrypts the `pg_dump`, runs the `pg_dump` back into `psql` to create the tables, and then copies the media folder back to its appropriate location.
- If you have used different variables from the `postgres_backup_cron` role, ensure they have been created and specified.
- General note: Unlike the `postgres_backup_cron` role, the `postgres_setup_recovery` role does not automatically run the recovery. It only creates a script that will initiate the recovery at `/usr/local/bin/postgres_recover_backup.sh`. The role to initiate a recovery is `postgres_recover_backup`.
- IATI website specific note: Due to some output from openssl, the current `postgres_recover_backup.sh` will throw an error about `salt`. This can be ignored, as `psql` will ignore the offending lines and initiate the rest of the database recreation.

We strongly recommend that you do yourself and others a favour by providing clear and thorough comments throughout your `postgres_backup.sh.j2` and `postgres_recover_backup.sh.j2` templates that fully explain what the code is doing. We hope our own templates provide good examples of this.
