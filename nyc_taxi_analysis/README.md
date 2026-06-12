# NYC Taxi Spatial-Temporal Demand Forecasting Pipeline

## 📌 Executive Summary
This repository contains an end-to-end data platform designed to predict localized, hourly taxi ride demand across New York City. By architecting a robust, production-grade feature store directly within a modern data cloud stack, this pipeline aggregates and scales millions of raw, chaotic ride logs into optimized temporal-spatial feature vectors. 

Using **dbt (Data Build Tool)** for modular transformations and orchestrating an **XGBoost Regressor via BigQuery ML**, the final model forecasts ride supply-and-demand dynamics with an exceptional **96.6% accuracy baseline ($R^2 = 0.9664$)**.

---

## 🏗️ System Architecture & Data Flow
The platform is designed around an ELT (Extract, Load, Transform) pattern, leveraging the cloud data warehouse as both a transformation engine and a high-performance machine learning computer.
[ Raw Taxi Layer ]
│
▼ (dbt staging & cleanup)
[ Staged Core Views ]
│
▼ (Spatial rounding & Windowing lag features)
[ Analytics Feature Store ]
│
▼ (BigQuery ML Train/Test Split)
[ Trained XGBoost Model ] ──> [ ML.PREDICT Automated Inference ] ──> [ Analytics Mart Layer ]

---

## 🛠️ The Tech Stack
* **Infrastructure & Data Warehouse:** Google BigQuery
* **Data Transformation & Engineering:** dbt (Data Build Tool) Core
* **Machine Learning Engine:** BigQuery ML (Boosted Tree Regressor / XGBoost)
* **Version Control:** Git & GitHub

---

## 💡 Core Engineering & Feature Store Highlights

Writing plain SQL isn't enough to capture complex human behavior across a major city. This project implements advanced analytics engineering patterns to give the machine learning model intense predictive power:

1. **Spatial Optimization (Geographical Gridding):** Raw GPS coordinates are precise floating points that structural tree models struggle to group effectively. I built a geographical rounding engine using `ROUND(pickup_latitude, 2)` and `ROUND(pickup_longitude, 2)` to discretize New York City into distinct neighborhood blocks.
2. **Temporal-Spatial Lookback Feature Store:** To help the algorithm capture historical momentum, I built an enterprise feature store leveraging advanced SQL window functions (`LAG()`) to create three lookback windows relative to each target time slot:
   * `no_of_trips_last_hr` (Short-term momentum / sudden trends)
   * `no_of_trips_last_day` (Daily cyclical commute patterns)
   * `no_of_trips_last_week` (Weekly baseline seasonality)

---

## 📊 Machine Learning Model Performance

The model was configured as a `boosted_tree_regressor` (XGBoost) using BigQuery ML, executing early-stopping at **14 iterations** to prevent training overfitting. It was evaluated on an entire month of future, completely unseen data (**March 2016**).

* **R-Squared ($R^2$):** **0.9664** * *Meaning:* The engineered time-series feature store successfully accounts for **96.6% of all variation** in taxi demand across New York City.
* **Median Absolute Error:** **2.70** * *Meaning:* For a typical neighborhood block at any given hour, the model's prediction is accurate to within **~3 rides** of reality.
* **Mean Absolute Error (MAE):** **16.31** * *Meaning:* The model tracks standard days perfectly (matching the low median error), but encounters larger margins of error during highly volatile, low-probability outlier periods (e.g., severe winter storms or major holiday spikes).

---

## ⚡ Data Consumption & Production View

The downstream dbt pipeline automatically materializes production predictions into a clean analytics mart table (`fct_demand_predictions`). This layer allows internal analysts, dispatch operations, and product teams to dynamically query future demand hot-spots directly using SQL:

-- Querying predicted high-demand hotspots for dispatch optimization
SELECT 
    pickup_datetime_tohr,
    spatial_pickup_latitude,
    spatial_pickup_longitude,
    actual_trips,
    predicted_trips,
    prediction_error
FROM 
    `nyc-taxi-with-dbt.dbt_dev.fct_demand_predictions`
WHERE 
    predicted_trips > 500
ORDER BY 
    predicted_trips DESC
LIMIT 100;

🚀 How To Run This Project Locally

### 1. Prerequisites
A Google Cloud Platform (GCP) account with BigQuery enabled.
Python 3.8+ and dbt-bigquery installed.

### 2. Installation & Setup
Clone this repository to your machine:

```bash
git clone [https://github.com/YOUR_GITHUB_USERNAME/nyc-taxi-demand-ml-pipeline.git](https://github.com/YOUR_GITHUB_USERNAME/nyc-taxi-demand-ml-pipeline.git)
cd nyc-taxi-demand-ml-pipeline
Verify your dbt database profile connection:

```bash
dbt debug
```
Run the entire transformation and feature engineering pipeline:

```bash
dbt run
```
