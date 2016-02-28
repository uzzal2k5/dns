;ipvdb.com forward zone
$ORIGIN ipvbd.com.
$TTL	86400
@	IN	SOA	ns1.ipvbd.com. admin.ipvbd.com.(
			1	; Serial
			3h	; Refresh after 3 hours
			1h	; Retry after 1 hour
			1w	; Retry after 1 week
			1h	; Negative caching TTL of 1 day
			)
;
;name servers - NS records
	IN	NS	dns1.ipvbd.com.
	IN	NS	ns1.ipvbd.com.
	IN	NS	ns2.ipvbd.com.
		IN	MX	10	mail.ipvbd.com.

; name servers - A records
	IN	A	192.168.8.204	
dns1	IN	A	192.168.8.204
ns1	IN	A	192.168.8.204
ns2	IN	A	192.168.8.203
ftp	IN	A	192.168.8.204
mail	IN	CNAME	ns1
www	IN	CNAME	ns1

;
; 192.168.8.0/24 - A records
shafiqpc	IN	A	192.168.8.62
ovirtengine	IN	A	192.168.8.209
ovirtnode	IN	A	192.168.8.210
