

# ------------------------------------------------------------------------------
# Create '/var/named/vbox.lab'
touch /var/named/vbox.lab
chgrp named /var/named/vbox.lab
chmod 664 /var/named/vbox.lab
chmod g+w /var/named


# ------------------------------------------------------------------------------
# Backup '/etc/named.conf'
cp /etc/named.conf /etc/named.conf.org
chmod 664 /etc/named.conf


# ------------------------------------------------------------------------------
# Update '/etc/named.conf'
sed -i -e 's/listen-on .*/listen-on port 53 { 192.168.56.101; };/' \
-e 's/allow-query .*/allow-query     { 192.168.56.0\/24; localhost; };\n        allow-transfer  { 192.168.56.0\/24; };/' \
-e '$azone "vbox.lab" {\n  type master;\n  file "vbox.lab";\n};\n\nzone "in-addr.arpa" {\n  type master;\n  file "in-addr.arpa";\n};' \
/etc/named.conf


# ------------------------------------------------------------------------------
# Create '/var/named/vbox.lab'
echo '$TTL 3H
@       IN SOA  oel72-oem13100        hostmaster      (
                                        101   ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                NS      oel72-oem13100
localhost       A       127.0.0.1
oel72-oem13100           A       192.168.56.101
oel72-odb12102-01        A       192.168.56.111
oel72-odb12102-02        A       192.168.56.112' \
> /var/named/vbox.lab


# ------------------------------------------------------------------------------
# Create '/var/named/in-addr.arpa'
echo '$TTL 3H
@       IN SOA  oel72-oem13100.vbox.lab.        hostmaster.vbox.lab.      (
                                        101   ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                NS      oel72-oem13100.vbox.lab. 

101.56.168.192   PTR     oel72-oem13100.vbox.lab.
111.56.168.192   PTR     oel72-odb12102-01.vbox.lab.
112.56.168.192   PTR     oel72-odb12102-02.vbox.lab.' \
> /var/named/in-addr.arpa


# ------------------------------------------------------------------------------
# Create '/dev/urandom'
rndc-confgen -a -r /dev/urandom


# ------------------------------------------------------------------------------
# Create '/etc/rndc.key'
chgrp named /etc/rndc.key
chmod g+r /etc/rndc.key
ls -lrta /etc/rndc.key


# ------------------------------------------------------------------------------
# Append nameserver to '/etc/resolv.conf'
echo '
nameserver 192.168.56.101' \
>> /etc/resolv.conf


# ------------------------------------------------------------------------------
# Append PEERDNS to 'ifcfg-enp0s3'
echo '
PEERDNS=no' \
>> /etc/sysconfig/network-scripts/ifcfg-enp0s3


# ------------------------------------------------------------------------------
# Restart named service
service named restart
