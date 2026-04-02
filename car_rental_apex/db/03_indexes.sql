-- ============================================================
-- Car Rental System (CRS) - Indexes
-- ============================================================

-- VEHICLES
CREATE INDEX idx_vehicle_category  ON crs_vehicles (category_id);
CREATE INDEX idx_vehicle_location  ON crs_vehicles (location_id);
CREATE INDEX idx_vehicle_status    ON crs_vehicles (status);
CREATE INDEX idx_vehicle_plate     ON crs_vehicles (plate_number);

-- CUSTOMERS
CREATE INDEX idx_customer_email    ON crs_customers (email);
CREATE INDEX idx_customer_license  ON crs_customers (license_number);
CREATE INDEX idx_customer_name     ON crs_customers (last_name, first_name);

-- RENTALS
CREATE INDEX idx_rental_customer   ON crs_rentals (customer_id);
CREATE INDEX idx_rental_vehicle    ON crs_rentals (vehicle_id);
CREATE INDEX idx_rental_status     ON crs_rentals (status);
CREATE INDEX idx_rental_dates      ON crs_rentals (rental_start_dt, rental_end_dt);
CREATE INDEX idx_rental_pickup     ON crs_rentals (pickup_location_id);
CREATE INDEX idx_rental_dropoff    ON crs_rentals (dropoff_location_id);

-- PAYMENTS
CREATE INDEX idx_payment_rental    ON crs_payments (rental_id);
CREATE INDEX idx_payment_date      ON crs_payments (payment_date);

-- MAINTENANCE
CREATE INDEX idx_maint_vehicle     ON crs_maintenance (vehicle_id);
CREATE INDEX idx_maint_date        ON crs_maintenance (service_date);
CREATE INDEX idx_maint_status      ON crs_maintenance (status);
