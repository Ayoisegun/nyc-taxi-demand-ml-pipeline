{{ config(materialized='table') }}

with raw_predictions as (
    SELECT
        -- Retaining time and spatial indices
        pickup_datetime_tohr,
        spatial_pickup_latitude,
        spatial_pickup_longitude,
        
        -- Target vs Prediction comparison metrics
        no_of_trips as actual_trips,
        ROUND(predicted_no_of_trips, 0) as predicted_trips,
        ROUND(predicted_no_of_trips - no_of_trips, 2) as prediction_error
    FROM
        ML.PREDICT(
            MODEL `nyc-taxi-with-dbt.dbt_dev.demand_boosted_tree`,
            (SELECT * FROM {{ ref('int_hourly_spatial_demand') }}) 
        )
    WHERE 
        -- Ensures we only write complete future records from March 2016
        pickup_datetime_tohr >= '2016-03-01 00:00:00'
)

SELECT 
    *,
    -- Additional downstream analytical fields for BI tool consumption
    ABS(prediction_error) as absolute_prediction_error,
    CASE 
        WHEN actual_trips > 0 THEN ROUND((ABS(prediction_error) / actual_trips) * 100, 2)
        ELSE 0 
    END as percentage_error
FROM 
    raw_predictions