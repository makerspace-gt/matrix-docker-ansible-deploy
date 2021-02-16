
## [Prerequisites](docs/prerequisites.md)

Setup Debian 10 VM https://one-1.4830.org/

|  CPU  |  RAM |   HDD |
| :---: | ---: | ----: |
|   1   | 2 GB | 10 GB |

## [Configuring DNS](docs/configuring-dns.md)

https://www.lima-city.de/usercp/domains/23721/records

| NS-Name                                | Typ   | Inhalt                            | Priority | TTL  |
| :------------------------------------- | :---- | :-------------------------------- | :------- | :--- |
| matrix.makerspace-gt.de                | A     | 193.26.120.232                    | 0        | 3600 |
| matrix.makerspace-gt.de                | AAAA  | 2a06:e881:1707:1:0:c1ff:fe1a:78e8 | 0        | 3600 |
| _matrix-identity._tcp.makerspace-gt.de | SRV   | 10 0 443 matrix.makerspace-gt.de  | 0        | 3600 |
| element.makerspace-gt.de               | CNAME | matrix.makerspace-gt.de           | 0        | 3600 |
| dimension.makerspace-gt.de             | CNAME | matrix.makerspace-gt.de           | 0        | 3600 |
| jitsi.makerspace-gt.de                 | CNAME | matrix.makerspace-gt.de           | 0        | 3600 |


## [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

1. get `vault-pass` from developer
2. run `./hooks/link.sh` to setup hooks


## [Configuring the Ansible playbook](docs/configuring-playbook.md)

1. `mkdir inventory/host_vars/matrix.makerspace-gt.de`
2. `cp examples/host-vars.yml inventory/host_vars/matrix.makerspace-gt.de/plain-vars.yml`
3. `edit inventory/host_vars/matrix.makerspace-gt.de/plain-vars.yml`
4. `cp examples/hosts inventory/hosts`
5. `edit inventory/hosts`

## [copy ssh keys](https://stackoverflow.com/a/48882051)

add task to `setup.yml`
```yaml
pre_tasks:
  - name: copy ssh keys
    # https://stackoverflow.com/a/48882051
    authorized_key:
      user: root
      key: "{% for key in query('fileglob', 'public_keys/*') %}{{ lookup('file', key) ~ '\n'}}{% endfor %}"
      exclusive: True
    tags: setup-all
```

## [Configuring FQDN](roles/GROG.fqdn/README.md)

1. `git submodule add https://github.com/GROG/ansible-role-fqdn.git roles/GROG.fqdn`
2. add role to `setup.yml`
   ```yaml
   - role: GROG.fqdn
     tags: setup-all
   ```

## [install unattended-upgrades](roles/jnv.unattended-upgrades/README.md)

1. `git submodule add https://github.com/jnv/ansible-role-unattended-upgrades.git roles/jnv.unattended-upgrades`
2. add role to `setup.yml`
   ```yaml
   - role: jnv.unattended-upgrades
     tags: setup-all
   ```

## [Installing](docs/installing.md)

1. `ansible-playbook -i inventory/hosts setup.yml --tags=setup-all --vault-password-file vault-pass`
2. `ansible-playbook -i inventory/hosts setup.yml --tags=start --vault-password-file vault-pass`

## [Configuring Service Discovery via .well-known](docs/configuring-well-known.md)

1. `ssh makerspace-gt@makerspace-gt.lima-ssh.de`
2. `nano wordpress_de-2017-11-08-9d823b/.htaccess`
   ```
   # BEGIN WordPress
   # Die Anweisungen (Zeilen) zwischen „BEGIN WordPress“ und „END WordPress“ sind
   # dynamisch generiert und sollten nur über WordPress-Filter geändert werden.
   # Alle Änderungen an den Anweisungen zwischen diesen Markierungen werden überschrieben.
   <IfModule mod_rewrite.c>
   RewriteEngine On

   RewriteCond %{REQUEST_URI} .well-known/matrix
   RewriteRule ^(.*)$ https://matrix.makerspace-gt.de/$1 [R,L]

   RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
   RewriteBase /
   RewriteRule ^index\.php$ - [L]
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule . /index.php [L]
   </IfModule>

   # END WordPress
   ```

## [Registering users](docs/registering-users.md)

`ansible-playbook -i inventory/hosts setup.yml --extra-vars='username=<your-username> password=<your-password> admin=<yes|no>' --tags=register-user --vault-password-file vault-pass`

## [Setup mautrix-telegram bridge](docs/configuring-playbook-bridge-mautrix-telegram.md)

1. pm botfather
   - !newbot
   - matrix-bridge
   - space_gt_bot
2. Edit vars.yml
   ```yaml
   matrix_mautrix_telegram_enabled: true
   matrix_mautrix_telegram_api_id: YOUR_TELEGRAM_APP_ID
   matrix_mautrix_telegram_api_hash: YOUR_TELEGRAM_API_HASH

   # Set up Double Puppeting
   # Method 1: automatically, by enabling Shared Secret Auth
   matrix_synapse_ext_password_provider_shared_secret_auth_enabled: true
   # You can put any string here, but generating a strong one is preferred (e.g. `pwgen -s 64 1`).
   matrix_synapse_ext_password_provider_shared_secret_auth_shared_secret: YOUR_SHARED_SECRET_GOES_HERE

   # If you want to use the relay-bot feature (relay bot documentation), which allows anonymous user to chat with telegram users, use the following additional playbook configuration:
   matrix_mautrix_telegram_bot_token: YOUR_TELEGRAM_BOT_TOKEN
   ```
3. `ansible-playbook -i inventory/hosts setup.yml --tags=etup-all,start --vault-password-file vault-pass`
4. start a chat with @telegrambot:makerspace-gt.de
5. !tg login
6. https://github.com/tulir/mautrix-telegram/wiki/Relay-bot