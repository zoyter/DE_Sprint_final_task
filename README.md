# DE_Sprint_final_task

## Итоговое задание по курсу "Инженер данных"

- **Тема:** Проект № 5.
- **Выполнил:** Ляш Олег Иванович

# Технологический стек:

- Сервер виртуализации: Proxmox Virtual Environment (https://www.proxmox.com/en/proxmox-ve)
- Виртуальная машина (контейнер): Debian (дистрибутив TurnKey-PostgreSQL https://www.turnkeylinux.org/postgresql)
- Сервер баз данных: PostgreSQL (https://www.postgresql.org/)
- Инструмент для работы с сервером баз данных: DataGrip (https://www.jetbrains.com/datagrip/)
- Оболочка для подключения к серверу: git-bash (https://git-scm.com/)

## Решение поставленной задачи:

### 1.Создаём базу данных

```sql
CREATE DATABASE "YellowTaxi"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE "YellowTaxi"
    IS 'Task about yellow taxi';
```

### 2. Создаём таблицу в соовтетствии с заданием для последующего импорта данных

> Доавлены значения по умолчанию (DEFAULT), т.к. в таблице есть пустые значения, которые при импорте давали сбой

```sql
CREATE TABLE public."raw_data"
(
    "VendorId" bigint DEFAULT 0,
    "Trep_pickup_datetime" timestamp without time zone ,
    "Trep_dropoff_datetime" timestamp without time zone,
    "Passanger_count" bigint DEFAULT -1,
    "Trip_distance" real DEFAULT -1,
    "Ratecodeid" bigint DEFAULT 0,
    "Store_and_fwd_flag" "char" DEFAULT ' ',
    "PulocationId" bigint DEFAULT 0,
    "Dolocationid" bigint DEFAULT 0,
    "Payment_type" bigint DEFAULT 0,
    "Fare_amount" real DEFAULT 0,
    "extra" real DEFAULT 0,
    "Mta_tax" real DEFAULT 0,
    "Tip_amount" real DEFAULT 0,
    "Tools_amount" real DEFAULT 0,
    "Improvement_surchange" real DEFAULT 0,
    "Total_amount" real DEFAULT 0,
    "Congestion_surchange" real DEFAULT 0
);

ALTER TABLE IF EXISTS public."raw_data"
    OWNER to postgres;
```

### 3. Импортируем данные

3.1 Копируем на сервер файл с сырыми данными

```shell
scp yellow_tripdata_2020-01.csv user1@192.168.3.165:/home/user1
```

3.2 Импортируем скопированные сырые данные в БД
```sql
# теперь импортируем
copy raw_data from '/home/yellow_tripdata_2020-01.csv' csv header;
copy raw_data2 from '/home/yellow_tripdata_2020-01_NEW.csv' DELIMITER ',' csv header;
```

> перед тем как импортировать данные были проделаны следующие действия:
>
> - Были взяты первые 100 строк из файла (head -n 100 yellow_tripdata_2020-01.csv > 1.csv)
> - Был проверен импорт на данных из файла 1.csv  с первой сотней строк
> - После того, как все прошло нормально таблица была удалена и создана заново
> - а уже затем был осуществелн импорт всех данных

3.3 Проверям все ли строки импортировались

3.3.1 В bash считаем строки в файле

```shell
wc -l yellow_tripdata_2020-01.csv
```
    | результат вместе с заголовком:
    | 6405009 yellow_tripdata_2020-01.csv
    | т.е. всего в файле 6405009-1 строка

3.3.2 делаем sql запрос на подсчёт строк в файле

```sql
select count(*) from raw_data;
```

    | результат: 6405008
    | т.е. в целом всё импортировалось удачно :-)
 
### 4. Извлекаем данные о поездах по дням, считаем проценты, мкасимумы и минимумы ну и пишем всё в новую таблицу

```sql
/*
WITH get_percents AS (
    SELECT
        -- считаем по каждому дню сколько было поезднок с целевым показателем кол-ва пассажирова (0,1,2,3,4 и более)
        DATE(r1."Trep_pickup_datetime") as d1,
        -- подменяем значение количества пассажирова на 1 если есть искомое кол-во или 0 если его нету и потом суммируем
        -- и так делаем для каждого искомого кол-ва пассажиров --------->>>
        sum(case when "Passanger_count" < 1 then 1 else 0 end) as "p0",        
        sum(case when "Passanger_count" = 1 then 1 else 0 end) as "p1",
        sum(case when "Passanger_count" = 2 then 1 else 0 end) as "p2",
        sum(case when "Passanger_count" = 3 then 1 else 0 end) as "p3",
        sum(case when "Passanger_count" >= 4 then 1 else 0 end) as "p4",
        -- <<<---------
        -- извлекаем максимальные и минимальные значения стоимости поездки
        -- и так делаем для каждого искомого кол-ва пассажиров--------->>>
        (SELECT min("Total_amount") from raw_data r2 where "Passanger_count"<1) as p0_min_money,
        (SELECT max("Total_amount") from raw_data r2 where "Passanger_count"<1) as p0_max_money,
        (SELECT min("Total_amount") from raw_data r2 where "Passanger_count"=1) as p1_min_money,
        (SELECT max("Total_amount") from raw_data r2 where "Passanger_count"=1) as p1_max_money,
        (SELECT min("Total_amount") from raw_data r2 where "Passanger_count"=2) as p2_min_money,
        (SELECT max("Total_amount") from raw_data r2 where "Passanger_count"=2) as p2_max_money,
        (SELECT min("Total_amount") from raw_data r2 where "Passanger_count"=3) as p3_min_money,
        (SELECT max("Total_amount") from raw_data r2 where "Passanger_count"=3) as p3_max_money,
        (SELECT min("Total_amount") from raw_data r2 where "Passanger_count">3) as p4_min_money,
        (SELECT max("Total_amount") from raw_data r2 where "Passanger_count">3) as p4_max_money
        -- <<<---------
FROM
    raw_data r1
GROUP BY
    DATE(r1."Trep_pickup_datetime")
ORDER BY
    DATE(r1."Trep_pickup_datetime")
)

SELECT
    -- а тут уже считаем процент по тем же целевым показателям, искомым значениям кол-ва пассажиров
    d1 as date,
    -- этот блок был для просмотра значений перед вычислением процентов  --------->>>
    --p0,p1,p2,p3,p4,
    --(p0+p1+p2+p3+p4) as summ,
    --date, percentage_zero, percentage_1p, percentage_2p, percentage_3p, percentage_4p_plus
    -- <<<---------
    (p0*100/NULLIF((p0+p1+p2+p3+p4),0)) as percentage_zero,
    (p1*100/NULLIF((p0+p1+p2+p3+p4),0)) as percentage_1p,
    (p2*100/NULLIF((p0+p1+p2+p3+p4),0)) as percentage_2p,
    (p3*100/NULLIF((p0+p1+p2+p3+p4),0)) as percentage_3p,
    (p4*100/NULLIF((p0+p1+p2+p3+p4),0)) as percentage_4p_plus,
    p0_min_money,
    p0_max_money,
    p1_min_money,
    p1_max_money,
    p2_min_money,
    p2_max_money,
    p3_min_money,
    p3_max_money,
    p4_min_money,
    p4_max_money

-- Вставка в новую таблицу
INTO parquet

FROM
    get_percents;
```