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