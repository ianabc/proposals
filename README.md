# Proposals

"Proposals" is a web application for accepting proposals for scientific meetings, such as workshops or conferences, and facilitating the peer-review and selection process at [BIRS](https://www.birs.ca).

See [the wiki](https://github.com/birs-math/proposals/wiki) for the intial specifications.


## Setup Instructions

1. Copy the `docker-compose.yml.example` file to `docker-compose.yml`.

2. Create the data containers if necessary, for persistent storage, as described at the top of the file.

3. Fill in the environment variables for usernames & passwords, and various seed keys, in the file.

4. ```docker-compose up``` to build & run the containers.

5. ```docker exec -it proposals bash``` to get a shell.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/dea8bb805d7444c78381750c42b30502)](https://www.codacy.com/gh/birs-math/proposals/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=birs-math/proposals&amp;utm_campaign=Badge_Grade)

[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/dea8bb805d7444c78381750c42b30502)](https://www.codacy.com/gh/birs-math/proposals/dashboard?utm_source=github.com&utm_medium=referral&utm_content=birs-math/proposals&utm_campaign=Badge_Coverage)

## Restoring from a backup
The following process should let you restore proposals from this repository and
a database dump.

1. Copy `docker-compose.yml.example` and update variables. Most of the defaults
   should be OK to get things of the ground, but if you want to continue using
   existing accounts without resetting passwords make sure you update
   `SECRET_KEY_BASE`, `SECRET_TOKEN`, `DEVISE_SECRET_KEY`, `DEVISE_PEPPER`
1. We will be using docker volumes to store the database, and various cached
   files. For consistency delete those volumes
   ```bash
   $ docker volume rm proposals_pgdata
   $ docker volume rm proposals_node_cache
   $ docker volume rm proposals_vendor_cache
   $ docker volume rm proposals_redis_data
   ```
1. Copy your database backup to a docker accessible location and prepare to add
   it to the db container as a volume
   ```bash
   $ mkdir -p ./db/backups
   $ cp db_proposals.sql ./db/backups
   $ vi docker-compose.yml
     ...
     - pgdata:/var/lib/postgresql/data
   + - ./db/backups:/var/backups
     ...
1. In the default configuration startup will initialize the database we want to
   restore. We can connect and re-initialize it manually (see
   `./db/pg-init/init-user.sh`).
   ```bash
   $ docker-compose up -d db
   $ docker-compose exec -u postgres db psql
   psql> DROP DATABASE proposals_development;
   psql> CREATE DATABASE 
            proposals_development
         OWNER 
            propuser 
         ENCODING 'UTF8'
         LC_COLLATE='en_US.utf8'
         LC_CTYPE='en_US.utf8';
   psql> GRANT ALL PRIVILEGES ON DATABASE 
            proposals_development
         TO
            propuser;
   psql> \q
   ```
   If for some reason you have already started the workshops component, it will
   have an active session against this database which might prevent you from
   `DROP`ing it. If so, you can try
   ```bash
   psql> SELECT
        pg_terminate_backend(pid)
   FROM
       pg_stat_activity
   WHERE
       -- don't kill my own connection!
       pid <> pg_backend_pid()
       -- don't kill the connections to other databases
       AND datname = 'proposals_development';
   ```
   before the `DROP`.
1. Restore the database from the dump file
   ```bash
   $ docker-compose exec -u postgres db bash
   $ psql -f /var/backups/db_proposals.sql proposals_development
   $ exit
   ```
1. Bring up the remaining workshops components. Depending on the build steps,
   this make take a long time.
   ```bash
   $ docker-compose up -d
   ```
1. For existing accounts to be able to authenticate, make sure you have
   configured the `DEVISE_*` and `SECRET_*` tokens in docker-compose.yml, one or
   more of them is involved in the password hashing step. If necessary (i.e. if
   you don't remember one of the admin accounts), use the
   workshops rails interface to reset the user password for the admin user.
   Below we are assuming you know the email address of an admin account on the
   instance you are migrating. If not, you can search by privilege level to find
   the account and then apply the same password update steps
   (`User.find_by_role('super_admin')`).
   ```bash
   $ docker-compose exec web bash
   $ rails c
   > u = User.find_by_email('sysadmin@example.com')
   > u.password = 'Some Funky New Password!"
   > u.save
   ```
You can now try logging in to the workshops interface on `http://127.0.0.1:3000`.

Depending on your account you may need to adjust your user roles, this should
probably be done through rails, but in a pinch, you can add e.g. user ID 40 to
the admin role via
```bash
$ docker-compose exec -u proposals db psql
psql> INSERT INTO user_roles 
    (role_id, user_id, created_at, updated_at)
  VALUES 
    (6, 40, current_timestamp, current_timestamp);
psql> \q
```



