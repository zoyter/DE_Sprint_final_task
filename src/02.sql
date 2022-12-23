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