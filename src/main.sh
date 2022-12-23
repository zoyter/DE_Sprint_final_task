#!/bin/bash
echo "Итоговое задание"
echo "(сценарий следует выполнять от имени администратора, например root)"
echo "(или изменить его для использования учетных данных конкретного пользователя)"
echo "--------------------------"

echo "\t 01.Создаём базу данных"
psql -f 01.sql
# time psql -f 01.sql
echo
echo "\t 02.Создаём таблицу"
psql -f 02.sql
# time psql -f 02.sql
echo
echo "\t 03.Импортируем данные"
psql -f 03.sql
# time psql -f 03.sql
echo
echo "\t 04.Выбираем данные, считаем и помещаем в новую таблицу"
psql -f 04.sql
# time psql -f 04.sql
echo