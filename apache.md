# Instalação Apache - CENTOS7

    yum install httpd -y
    yum install memcached

  
 # httpd.conf
  
  Para evitar erros nos log do SIP (menu Infra/Log) identificados por “Microsoft Data Access Internet Publishing Provider Protocol 
Discovery” (gerados quando o Microsoft Office varre links que foram inseridos nos documentos) colocar no httpd.conf: 

    SetEnvIfNoCase user-agent  "Microsoft Data Access Internet Publishing Provider Protocol Discovery" bad_bot=1 
    <FilesMatch "(.*)"> 
       Order Allow,Deny 
       Allow from all 
       Deny from env=bad_bot 


   ### Customizações SEI (Documentação)


     KeepAlive On
    MaxKeepAliveRequests 100
    KeepAliveTimeout 15

    <IfModule prefork.c>
            StartServers 20
            MinSpareServers 10
            MaxSpareServers 30
            ServerLimit 2000
            MaxClients 2000
            MaxRequestsPerChild 0
    </IfModule>

    <IfModule worker.c>
            StartServers 3
            MaxClients 150
            MinSpareThreads 25
            MaxSpareThreads 75
            ThreadsPerChild 25
            MaxRequestsPerChild 10000
    </IfModule>

    ########### Ajustes SEI DOCUMENTACAO ############


    <Directory />
        AllowOverride all
        Require all denied
    </Directory>

### Memcached

- etc/sysconfig/memcached

        PORT="11211"
        USER="memcached"
        MAXCONN="4096"
        CACHESIZE="2048"
        OPTIONS=""

