# Instalação SEI - WEBSERVER 

- Centos7 
- Apache
- Memcached
- PHP56

# Script Shell - INSTALAÇÃO WEBSERVER

- [Script de instalação SEI](https://github.com/ederbritodf/sei/blob/master/sei-httpd.sh)



# Upstream SEI NGINX

    upstream homolog-sei.com.br {
            ip_hash;
            server 10.1.0.133;
            server 10.1.0.130;
            keepalive 32;
        }

        server {
            listen 80;
            listen [::]:80;
            server_name homolog-sei.com.br;

    #file-size

            client_max_body_size 6144M;

    #ssl
            listen 443 ssl;
            listen [::]:443 ssl;
            ssl_certificate     /etc/nginx/ssl/fullchain1.pem;
            ssl_certificate_key /etc/nginx/ssl/privkey1.pem;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
            ssl_prefer_server_ciphers on;
            ssl_ciphers                 ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256;
    #logs
            access_log      /var/log/nginx/homolog-sei.access.log main;
            error_log       /var/log/nginx/homolog-sei.error.log warn;

    # force https-redirects
        if ($scheme = http) {
            return 301 https://$server_name$request_uri;
    }

            location / {

                    proxy_next_upstream     error timeout invalid_header http_500;
                    proxy_connect_timeout   3;
                    proxy_pass              http://homolog-sei.com.br;
                   proxy_set_header           X-Real-IP   $remote_addr;
                   proxy_set_header           X-Forwarded-For  \$proxy_add_x_forwarded_for;
                   proxy_set_header           X-Forwarded-Proto  $scheme;
                   proxy_set_header           X-Forwarded-Server  $host;
                   proxy_set_header           X-Forwarded-Host  $host;
                   proxy_redirect http:// https://;
           }
    }
