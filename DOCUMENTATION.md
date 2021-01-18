
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


## [Configuring the Ansible playbook](docs/configuring-playbook.md)

1. `mkdir inventory/host_vars/matrix.makerspace-gt.de`
2. `cp examples/host-vars.yml inventory/host_vars/matrix.makerspace-gt.de/vars.yml`
3. `edit inventory/host_vars/matrix.makerspace-gt.de/vars.yml`
4. `cp examples/hosts inventory/hosts`
5. `edit inventory/hosts`

## [Configuring FQDN](roles/GROG.fqdn/README.md)

1. `git submodule add https://github.com/GROG/ansible-role-fqdn.git roles/GROG.fqdn`
2. add role to `setup.yml`
   ```yaml
   - role: GROG.fqdn
     tags: setup-all
   ```

## [Installing](docs/installing.md)

1. `ansible-playbook -i inventory/hosts setup.yml --tags=setup-all`
2. `ansible-playbook -i inventory/hosts setup.yml --tags=start`

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

`ansible-playbook -i inventory/hosts setup.yml --extra-vars='username=<your-username> password=<your-password> admin=<yes|no>' --tags=register-user`