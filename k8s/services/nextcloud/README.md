# NextCloud

## Notes

```bash
echo "RemoteIPInternalProxy 10.0.0.0/8" >> /etc/apache2/conf-enabled/remoteip.conf
/etc/apache2/apache2.conf: %h -> %a

-------

Create CM and mount as extra volume to
    /etc/apache2/conf-enabled/remoteip.conf
    and /etc/apache2/conf-enabled/logformat.conf
```
