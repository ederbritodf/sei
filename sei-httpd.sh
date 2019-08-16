#!/bin/bash

#################################################################
#  Data: 16.08.2019                                             #
#  Autor: Eder Brito Queiroz de Oliveira                        #
#  Observacao: Script que realizar instalação do webserver SEI. #
#################################################################

PHP=/etc/php.ini
CONFIGMEMCACHED=/etc/sysconfig/memcached
SELINUX=/etc/sysconfig/selinux
DIR=/opt

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

	rpm -qa httpd
        
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

        rpm -qa memcached

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
	echo max_input_vars = 200 >> $PHP
	echo magic-quotes-gpc = 0 >> $PHP
	echo magic_quotes_runtime = 0 >> $PHP
	echo magic_quotes_sysbase = 0 >> $PHP
	sed -i "s/UTF-8/ISO-8859-1/g" $PHP
	sed -i "s/1440/2880/g" $PHP
	sed -i "663s/8M/40M/g" $PHP
	sed -i "811s/2M/20M/g" $PHP
      }

SELINUX(){

        echo "--------------------"
        echo "DESABILITA SELINUX"
	sed -i "s/enforcing/disabled/g" $SELINUX
	setenforce 0
	getenforce
      }

GIT(){

	 echo "--------------------"
	 echo "INSTALA GIT"
	 yum install git -y


     }


SEI(){

        echo "--------------------"
        echo "CONFIGURA APLICAÇÃO SEI"
	echo "DOWNLOAD SEI GITHUB - EDERBRITODF"
	echo "--------------------"
	echo " VERIFICA GIT "
	rpm -qa git

                if [ $? -eq 0 ]
                then
                  echo " ++ GIT instalado ++"
                else
		  GIT
                fi
       echo "DOWNLOAD VERSÃO 3.0" 
       wget https://github.com/ederbritodf/sei/blob/master/SEI-Fontes-v3.0.0.tar.gz
       echo "DESCOMPACTA SEI"
	tar -zxvf SEI-Fontes-v3.0.0.tar.gz -C /opt/
	
     }


#APACHE
#MEMCACHED
#PHP56
PHPINI
SELINUX
SEI
