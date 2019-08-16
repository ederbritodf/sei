# Instalação SEI - WEBSERVER 

- Centos7 
- Apache
- Memcached
- PHP56

# Script Shell - INSTALAÇÃO WEBSERVER

- [Script de instalação SEI](https://github.com/ederbritodf/sei/blob/master/sei-httpd.sh)

    #!/bin/bash

    #################################################################
    #  Data: 16.08.2019                                             #
    #  Autor: Eder Brito Queiroz de Oliveira                        #
    #  Observacao: Script que realizar instalação do webserver SEI. #
    #################################################################

    PHP=/etc/php.ini
    CONFIGMEMCACHED=/etc/sysconfig/memcached



    #INSTALL APACHE

    APACHE(){
            echo "--------------------"
            echo "INSTALA APACHE"
        echo "+httpd"
        yum install httpd -y
        echo "HABILITA INICIALIAÇÃO S.O"
        echo "enable httpd"
            /usr/bin/systemctl enable httpd
        echo "INICIALIZA SERVIÇO"
        echo "+start httpd"
            /usr/bin/systemctl start httpd
        echo "VERIFICA PROCESSOS ATIVOS"
        echo "+ps aux"
        ps aux | grep httpd |awk -F " " '{print $1,$2}'

            # ---- Verifica instalacao httpd ---- #

        rpm -qa | grep httpd

            if [ $? -eq 0 ] 
            then
                  echo " ++ HTTPD instalado ++"
                else
                  echo " -- HTTPD falhou --"
                fi
        }


    MEMCACHED(){
        echo "--------------------"
        echo "INSTALAÇÃO MEMCACHED"
            echo "+memcached"
            yum install memcached -y
            echo "HABILITA INICIALIZAÇÃO"
            echo "enable memcached"
            /usr/bin/systemctl enable memcached
            echo "INICIALIZA SERVIÇO"
            echo "+start memcached"
            /usr/bin/systemctl start memcached
            echo "VERIFICA PROCESSOS ATIVOS"
            echo "+ps aux"
            ps aux | grep memcached |awk -F " " '{print $1,$2}'

            # ---- Verifica instalacao httpd ---- #

            rpm -qa | grep memcache

                if [ $? -eq 0 ]
                 then
                  echo " ++ MEMCACHED instalado ++"
                else
                  echo " -- MEMCACHED falhou --"
                fi

        ### Por padrão o memcached vem configurado MAXCONN=1024MB e CACHESIZE=64
        ### Vamos alterar esses valores para o indicado na Documentação SEI

        #Substituindo o valor MAXCONN=1024 para MAXCONN=4096
        sed -i "s/1024/4096/g" $CONFIGMEMCACHED

            #Substituindo o valor CACHESIZE=64 para MAXCONN=1028
            sed -i "s/64/1028/g" $CONFIGMEMCACHED

        #Aplicando alterações
        echo "APLICANDO ALTERAÇÕES"
            echo "REINICIALIZA SERVIÇO"
            echo "+restart memcached"
            /usr/bin/systemctl restart memcached
            echo "VERIFICA PROCESSOS ATIVOS"
        echo "+ps aux"
            ps aux | grep memcached |awk -F " " '{print $1,$2}'
        echo "PRINTA CONFIG"
        cat $CONFIGMEMCACHED

        }


    PHP56(){

        #Configuração Repositorios PHP
        echo "--------------------"
            echo "CONFIGURANDO REPOSITÓRIOS PHP"
        yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
        yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
        yum install yum-utils -y
        yum-config-manager --enable remi-php56
        yum info php | grep "Versão"
        yum info php | grep Versão |awk -F ":" '{print $2}' > versaophp
        echo "====="
        echo "Versão de PHP Configurada:" | cat versaophp
            echo "====="

        #Instalação PHP
        echo "--------------------"
            echo "INSTALAÇÃO PHP56"
        yum install php php-snmp php-intl php-process php-imap php-embedded php-pecl-imagick-devel php-pdo php-pecl-imagick php-mssql php-mcrypt php-bcmath php-mbstring php-soap php-odbc php-xml php-dba php-gd php-opcache php-ldap php-pecl-memcached php-devel php-pear php-cli php-pecl-memcache -y
        #Arquivo PHP.INI
        echo "Arquivo de configuração php.ini"
        php -i | grep "Loaded"
        }

    PHPINI(){
        #Verificar os itens abaixo no arquivo php.ini dos servidores que rodam o SEI/SIP
        echo "--------------------"
        echo "CUSTOMIZACOES SEI - PHP.INI"
        echo "########################" >> $PHP
        echo "## CUSTOMIZACOES SEI ##" >> $PHP
        echo "########################" >> $PHP
        echo include_path = "/opt/infra/infra_php" >> $PHP
        sed -i "s/UTF-8/ISO-8859-1/g" $PHP
        sed -i "s/1440/2880/g" $PHP

        }


    APACHE
    MEMCACHED
    PHP56
    PHPINI



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
