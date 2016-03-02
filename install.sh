#!/bin/sh
#************************************************************************************************************************
# It is a simple script that would create a domain server installation and configuration with BIND.                     *
# Executor just need to put the domain name (i,e; example.com ) in the middle of script after run with sh command.      *
# It will do almost everything with partial dynamic by backing up original named.conf                                   *
# and create zone, reverse zone with there db.                                                                          *
# At finally it will show the outcome with digging                                                                      *
# Creator: Md Shafiqul Islam                                                                                            *
# Contact : +8801715519132 E-Mail: uzzal2k5@gmail.com                                                                   *
#************************************************************************************************************************
yum install bind* -y
inet_dev=`ip a | grep inet | awk -F' ' '{ print $7 }'`;
eth_ip=$(ip addr list ${inet_dev} |grep "inet " |cut -d' ' -f6|cut -d/ -f1)
cd /etc	
FILE=named.conf.original
if [ -f $FILE ];
then
echo "File exist and not Overrite"
else
cp  named.conf $FILE
fi
sed -i 's/127.0.0.1;/127.0.0.1; '${eth_ip}'; /g' named.conf
sed -i 's/localhost;/any; /g' named.conf
firewall-cmd --add-service=dns --permanent
firewall-cmd --reload
mkdir -p /etc/bind/zones/master
echo "What is your domain name? ["$(hostname)"]: " 
read my_domain
# Root Domain zone Created 
zone="
zone \"${my_domain}\" IN {
        type master;
        file \"/etc/bind/zones/master/db.${my_domain}\";
        allow-update { none; };
};

"
# Cut & Reverse IP [example: 192.168.8.210 to 8.168.192 ] 
#rev_ip=`echo $eth_ip | cut -d'.' -f1-3`
rev_ip=`echo $eth_ip | awk -F'.' '{print $3,$2,$1}' OFS='.'`
net_ip=`echo $eth_ip | awk -F'.' '{print $1,$2,$3}' OFS='.'`
rev_net=`echo $eth_ip | awk -F'.' '{print $4}'`
# Reverse Zone Created
rev_zone="
zone \"${rev_ip}.in-addr.arpa\" IN {
        type master;
        file \"/etc/bind/zones/master/db.${rev_ip}.zones\";
        allow-update { none; };
};
"
echo "$zone">>/etc/named.rfc1912.zones
echo "$rev_zone">>/etc/named.rfc1912.zones
# Root Domain DB Record
root_domain="
;${my_domain} forward zone
\$ORIGIN ${my_domain}.
"
# Common Parameter for Domain DB Record
common_param="
\$TTL	86400
@	IN	SOA	ns1.${my_domain}. admin.${my_domain}.(
			1	; Serial
			3h	; Refresh after 3 hours
			1h	; Retry after 1 hour
			1w	; Retry after 1 week
			1h	; Negative caching TTL of 1 day
			)
;
"
# Root Domain DB Record definition
root_domain_record="
;name servers - NS records
	IN	NS	dns1.${my_domain}.
	IN	NS	ns1.${my_domain}.
	IN	MX	10	mail.${my_domain}.

; name servers - A records
	IN	A	${eth_ip}	
dns1	IN	A	${eth_ip}
ns1	IN	A	${eth_ip}
mail	IN	CNAME	ns1
www	IN	CNAME	ns1
;
;${net_ip}.0/24 - A records
"
# Reverse Domain for root domain definition
rev_domain="
;Reverse zone db for ${my_domain}
\$ORIGIN ${rev_ip}.in-addr.arpa.
"
# Reverse Record definition
reverse_record="
; name servers - NS records
@	IN	NS      ns1.${my_domain}.
; PTR Records
${rev_net}	IN	PTR	ns1.${my_domain}.
"
cd /etc/bind/zones/master
touch db.${my_domain}
touch db.${rev_ip}.zones
echo "$root_domain"> db.${my_domain}
echo "$common_param">> db.${my_domain}
echo "$root_domain_record">> db.${my_domain}
#
echo "$rev_domain">db.${rev_ip}.zones
echo "$common_param">>db.${rev_ip}.zones
echo "$reverse_record">>db.${rev_ip}.zones 
systemctl restart named
systemctl enable named
systemctl status -l named
echo "nameserver 127.0.0.1">/etc/resolv.conf
cat /etc/resolv.conf
# DNS Testing
dig @${eth_ip} ${my_domain}


