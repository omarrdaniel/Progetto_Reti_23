$ORIGIN progetto.com.
$TTL 1h
progetto.com. IN SOA ns.progetto.com. admin.progetto.com. ( 1 43200 1440 345600 7200 )
progetto.com. IN NS ns.progetto.com.
ns.progetto.com. IN A 192.168.0.35
http.progetto.com. IN A 192.168.0.34
ftp.progetto.com. IN A 192.168.0.33
pc3.progetto.com. IN A 192.168.0.41
admin.progetto.com. IN A 192.168.0.2
dhcp.progetto.com. IN A 192.168.0.1
www.progetto.com. IN CNAME http.progetto.com.
