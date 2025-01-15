# Monitor processes in mariadb

NOW=$(date +%Y%m%d_%H%M%S)
mariadb --defaults-extra-file=~/secret/secret.cnf --table -e "show processlist\G" | grep Info | grep -v processlist | grep -v "Info: NULL" | tee "${NOW}.txt";

