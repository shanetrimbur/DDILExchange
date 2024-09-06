# Kickstart file for standalone on-premises collaboration server

# System settings
install
text
url --url="http://mirror.centos.org/centos/7/os/x86_64/"

# Partitioning
part /boot --fstype xfs --size=1024
part pv.01 --size=1 --grow
volgroup my_vg pv.01
logvol / --fstype xfs --name=root --vgname=my_vg --size=10240
logvol /home --fstype xfs --name=home --vgname=my_vg --size=20480

# Root password
rootpw --iscrypted $1$xyz$ABCDEF1234567890ABCDEF

# Network configuration
network --bootproto=static --ip=192.168.1.10 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=8.8.8.8 --hostname=collabserver.local

# Timezone
timezone --utc America/New_York

# Bootloader
bootloader --location=mbr --timeout=5 --append="rhgb quiet"

# Reboot after installation
reboot

# Package installation
%packages
@core
postfix
dovecot
roundcubemail
nginx
radicale
nextcloud
openssl
clamav
spamassassin
rsnapshot
keepalived
haproxy
ispconfig
baikal
%end

# Post-install configuration
%post

# Create folder and file structure
mkdir -p /var/lib/radicale/collections
mkdir -p /var/mail
mkdir -p /var/backups/rsnapshot
mkdir -p /var/www/html/nextcloud/config
mkdir -p /var/www/html/nextcloud/data
mkdir -p /var/spool/postfix
mkdir -p /etc/keepalived
mkdir -p /var/log
mkdir -p /usr/share/roundcubemail

# Create Postfix main.cf configuration file
cat > /etc/postfix/main.cf <<EOF
myhostname = collabserver.local
mydomain = localdomain
myorigin = \$mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = \$myhostname, localhost.\$mydomain, localhost
relayhost =
mynetworks = 192.168.1.0/24
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP
EOF

# Create Dovecot dovecot.conf configuration file
cat > /etc/dovecot/dovecot.conf <<EOF
protocols = imap pop3
listen = *
mail_location = maildir:/var/mail/%d/%n
ssl = required
ssl_cert = </etc/ssl/certs/dovecot.pem
ssl_key = </etc/ssl/private/dovecot.pem
auth_mechanisms = plain login
EOF

# Create Nginx config for Roundcube
cat > /etc/nginx/conf.d/roundcube.conf <<EOF
server {
    listen 80;
    server_name collabserver.local;

    root /usr/share/roundcubemail;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

# Create Roundcube config.inc.php
cat > /etc/roundcubemail/config.inc.php <<EOF
<?php
\$config['default_host'] = 'localhost';
\$config['smtp_server'] = 'localhost';
\$config['smtp_port'] = 25;
\$config['support_url'] = '';
\$config['log_dir'] = '/var/log/roundcube/';
\$config['temp_dir'] = '/tmp/';
\$config['enable_caching'] = true;
?>
EOF

# Create Radicale config for CalDAV and CardDAV
cat > /etc/radicale/config <<EOF
[server]
hosts = 0.0.0.0:5232

[auth]
type = htpasswd
htpasswd_filename = /etc/radicale/users
htpasswd_encryption = bcrypt

[storage]
type = filesystem
filesystem_folder = /var/lib/radicale/collections

[rights]
type = owner_only
EOF

# Create rsnapshot configuration file
cat > /etc/rsnapshot.conf <<EOF
snapshot_root    /var/backups/rsnapshot/
no_create_root   1
retain           daily 7
retain           weekly 4
retain           monthly 3
EOF

# Create Nextcloud config.php
cat > /var/www/html/nextcloud/config/config.php <<EOF
<?php
\$CONFIG = array (
  'instanceid' => 'oc1234567890',
  'trusted_domains' => array (
    0 => '192.168.1.10',
  ),
  'datadirectory' => '/var/www/html/nextcloud/data',
  'dbtype' => 'sqlite3',
  'version' => '22.1.1',
  'installed' => true,
);
?>
EOF

# Set ownership for Nextcloud directories
chown -R nginx:nginx /var/www/html/nextcloud

# Create the Postfix mail queue directory
mkdir -p /var/spool/postfix/queue
chown -R postfix:postfix /var/spool/postfix

# Enable and start essential services
systemctl enable postfix dovecot nginx radicale nextcloud
systemctl start postfix dovecot nginx radicale nextcloud

# Create Keepalived configuration (for high availability)
cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secret
    }
    virtual_ipaddress {
        192.168.1.254
    }
}
EOF

# Set up maildir for user mailboxes
mkdir -p /var/mail/example_user/Maildir/{cur,new,tmp}
chown -R example_user:mail /var/mail/example_user/Maildir

%end
