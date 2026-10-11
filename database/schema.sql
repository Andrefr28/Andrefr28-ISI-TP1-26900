CREATE TABLE IF NOT EXISTS airports (
    airport_code VARCHAR(10) PRIMARY KEY,
    airport_name VARCHAR(255) NOT NULL,
    city VARCHAR(120),
    country VARCHAR(120),
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6)
);

CREATE TABLE IF NOT EXISTS flights (
    flight_id SERIAL PRIMARY KEY,
    flight_date DATE NOT NULL,
    airline_code VARCHAR(20),
    airline_name VARCHAR(255),
    origin_airport_code VARCHAR(10) REFERENCES airports(airport_code),
    destination_airport_code VARCHAR(10),
    scheduled_departure TIMESTAMP,
    actual_departure TIMESTAMP,
    departure_delay_minutes NUMERIC(8, 2),
    is_delayed BOOLEAN
);

CREATE TABLE IF NOT EXISTS weather_hourly (
    weather_id SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) REFERENCES airports(airport_code),
    observed_at TIMESTAMP NOT NULL,
    temperature_c NUMERIC(6, 2),
    precipitation_mm NUMERIC(8, 2),
    wind_speed_kmh NUMERIC(8, 2),
    weather_code INTEGER
);

CREATE TABLE IF NOT EXISTS etl_logs (
    log_id SERIAL PRIMARY KEY,
    process_name VARCHAR(120) NOT NULL,
    source_name VARCHAR(120),
    rows_processed INTEGER DEFAULT 0,
    status VARCHAR(40) NOT NULL,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
