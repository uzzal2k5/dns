;
; BIND data file for mysite.me
;
$TTL    3h
@       IN      SOA       monitor.ipvision.com. admin.monitor.ipvision.com. (
                          1        ; Serial
                          3h       ; Refresh after 3 hours
                          1h       ; Retry after 1 hour
                          1w       ; Expire after 1 week
                          1h )     ; Negative caching TTL of 1 day
;

@       IN      NS      ns1.ipvbd.com.
@       IN      NS      ns2.ipvbd.com.

monitor.ipvision.com.		IN      A       192.168.8.79
www 				IN      A       192.168.8.79

