{{ config(materialized='view') }}

with source_data as (
    SELECT * FROM {{ source('staging', 'yellow_trips') }}
)

SELECT
    -- 1. Identifiers
    CAST(VendorID as string) as vendor_id,
    CAST(RateCodeID as string) as rate_code_id,
    
    -- 2. Timestamps
    CAST(tpep_pickup_datetime as timestamp) as pickup_datetime,
    EXTRACT(hour from CAST(tpep_pickup_datetime as timestamp)) as hour_of_day,
    FORMAT_TIMESTAMP('%A', CAST(tpep_pickup_datetime as timestamp)) as day_of_week,
    CAST(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- 3. Trip Info
    passenger_count,
    trip_distance,
    
    -- 4. Financials
    fare_amount,
    tip_amount,
    total_amount,

    -- 5. Location
    CAST(pickup_longitude as NUMERIC) as pickup_longitude,
    CAST(pickup_latitude as NUMERIC) as pickup_latitude,
    

    --6. Spatial Dimensions
    ROUND(pickup_longitude, 2) as spatial_pickup_longitude,
    ROUND(pickup_latitude, 2) as spatial_pickup_latitude



FROM source_data
WHERE passenger_count > 0 
  AND trip_distance > 0
  AND fare_amount > 0