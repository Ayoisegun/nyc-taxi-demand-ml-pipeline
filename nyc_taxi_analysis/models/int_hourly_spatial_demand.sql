{{ config(materialized='view') }}

with source_data as (
    select * from {{ ref('stg_yellow_trips') }}
),

base_cte as(
    SELECT
        TIMESTAMP_TRUNC(pickup_datetime, hour) as pickup_datetime_tohr,
        SUM(passenger_count) as total_passengers,
        CAST(spatial_pickup_latitude as string) as spatial_pickup_latitude,
        CAST(spatial_pickup_longitude as string) as spatial_pickup_longitude,
        COUNT(*) as no_of_trips,
        ROUND(AVG(fare_amount), 2) as avg_fare,
        ROUND(AVG(trip_distance), 2) as avg_distance
    FROM
        source_data
    GROUP BY             
        TIMESTAMP_TRUNC(pickup_datetime, hour),
        spatial_pickup_latitude,
        spatial_pickup_longitude
),
lag_cte as(
    SELECT 
        pickup_datetime_tohr,
        total_passengers,
        spatial_pickup_latitude,
        spatial_pickup_longitude,
        no_of_trips,
        avg_fare,
        avg_distance,   
        COALESCE(LAG(no_of_trips, 1) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr), 0) as no_of_trips_last_hr,
        LAG(no_of_trips, 24) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr) as no_of_trips_last_day,
        LAG(no_of_trips, 168) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr) as no_of_trips_last_week,
        LAG(avg_fare, 1) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr) as avg_fare_last_hr,
        LAG(avg_fare, 24) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr) as avg_fare_last_day,
        LAG(avg_fare, 168) OVER (PARTITION BY spatial_pickup_latitude, spatial_pickup_longitude ORDER BY pickup_datetime_tohr) as avg_fare_last_week

    FROM base_cte)

SELECT
    *
    FROM lag_cte
WHERE
    no_of_trips_last_day IS NOT NULL and
    no_of_trips_last_week IS NOT NULL
