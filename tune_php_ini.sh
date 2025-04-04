#!/usr/bin/env bash

upload_max_filesize=32M
post_max_size=48M
memory_limit=256M
max_execution_time=600
max_input_vars=3000
max_input_time=1000

# find major version of installed PHP
PHP_VERSION=$(php -v | tac | tail -n 1 | cut -d " " -f 2 | cut -c 1-3)

for key in upload_max_filesize post_max_size memory_limit max_execution_time max_input_vars max_input_time
do
 sed -i "s/^\($key\).*/\1 $(eval echo = \${$key})/" /etc/php/$PHP_VERSION/fpm/php.ini
done