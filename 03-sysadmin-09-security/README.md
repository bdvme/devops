*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 3.9 Элементы безопасности информационных систем

1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.

###### Ответ:



2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.

###### Ответ:


3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.

###### Ответ:

```bash
vagrant@vagrant:~$ sudo apt-get install apache2
vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
vagrant@vagrant:~$ sudo openssl x509 -text -noout -in  /etc/ssl/certs/apache-selfsigned.crt | grep Subject:
        Subject: C = RU, ST = Moscow, L = Moscow, O = TestComp, CN = www.test.net
vagrant@vagrant:~$ cat /etc/apache2/sites-available/test.conf
        <IfModule mod_ssl.c>
        <VirtualHost *:443>
           ServerName test.net
           DocumentRoot /var/www/test.net
           SSLEngine on
           SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
           SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
        </VirtualHost>
        </IfModule>
vagrant@vagrant:~$ sudo ln -s /etc/apache2/sites-available/test.conf /etc/apache2/sites-enabled/test.conf
```
4. Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).

###### Ответ:


5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.

###### Ответ:


6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

###### Ответ:


7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

###### Ответ:
