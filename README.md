# Hello world from flask #
### Python + Apache2 + WSGI + Flask  ###

#### Usage: ####

* Install required packages:

```
sudo apt install python-pip apache2 libapache2-mod-wsgi
```


* Fix permissions in your server (if necessary):

```
sudo chown -R bob /var/www
sudo chown -R bob /etc/apache2
```

* Configure your virtual environment and make the config file for the site

```
pip install virtualenv
sudo /usr/bin/easy_install virtualenv
cd /var/www/myfirstapp/
virtualenv env
vim /etc/apache2/sites-available/hello.conf
```
* Insert the configuration for the flask app

```
<VirtualHost *>
    ServerName example.com
    WSGIScriptAlias / /var/www/firstapp/hello.wsgi
    WSGIDaemonProcess hello python-path=/var/www/firstapp:/var/www/firstapp/env/lib/python2.7/site-packages
    <Directory /var/www/firstapp>
       WSGIProcessGroup hello
       WSGIApplicationGroup %{GLOBAL}
        Order deny,allow
        Allow from all
    </Directory>
</VirtualHost>
```

* Disable the default site and enable our hello.conf site, finally reload the apache.

```
sudo a2dissite 000-default.conf
sudo a2ensite hello.conf
sudo service apache2 reload

```
