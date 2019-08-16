# Instalação apache versão 5.6.40 - Centos 7

### Configuração de repositório para o php56

    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum install yum-utils -y
    yum-config-manager --enable remi-php56
    yum info php
  
  ### Instalação Pacotes PHP
  
    yum install php php-snmp php-intl php-process php-imap php-embedded php-pecl-imagick-devel php-pdo php-pecl-imagick php-mssql php-mcrypt php-bcmath php-mbstring php-soap php-odbc php-xml php-dba php-gd php-opcache php-ldap php-pecl-memcached php-devel php-pear php-cli php-pecl-memcache
