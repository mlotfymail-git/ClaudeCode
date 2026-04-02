-- ============================================================
-- Car Rental System (CRS) - Sample Data
-- ============================================================

-- LOCATIONS
INSERT INTO crs_locations (location_name, address, city, state, postal_code, phone, email)
VALUES ('Downtown Branch',   '100 Main Street',       'New York',    'NY', '10001', '212-555-0101', 'downtown@crs.com');
INSERT INTO crs_locations (location_name, address, city, state, postal_code, phone, email)
VALUES ('Airport Terminal',  '1 Airport Blvd',        'New York',    'NY', '11430', '212-555-0202', 'airport@crs.com');
INSERT INTO crs_locations (location_name, address, city, state, postal_code, phone, email)
VALUES ('Midtown Office',    '500 5th Avenue',        'New York',    'NY', '10036', '212-555-0303', 'midtown@crs.com');
INSERT INTO crs_locations (location_name, address, city, state, postal_code, phone, email)
VALUES ('LA Downtown',       '250 Sunset Blvd',       'Los Angeles', 'CA', '90028', '310-555-0101', 'la.downtown@crs.com');
INSERT INTO crs_locations (location_name, address, city, state, postal_code, phone, email)
VALUES ('LAX Airport',       '1 World Way',           'Los Angeles', 'CA', '90045', '310-555-0202', 'lax@crs.com');

-- VEHICLE CATEGORIES
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('ECON', 'Economy',   'Compact and fuel-efficient vehicles',        35.00,  210.00,  750.00,  150.00, 4);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('COMP', 'Compact',   'Slightly larger than economy, great value',  45.00,  270.00,  950.00,  200.00, 5);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('MIDZ', 'Midsize',   'Comfortable midsize sedans',                 60.00,  360.00, 1200.00,  250.00, 5);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('FULL', 'Full-size', 'Spacious full-size sedans',                  75.00,  450.00, 1500.00,  300.00, 5);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('SUV',  'SUV',       'Sport utility vehicles for families',        95.00,  570.00, 1900.00,  400.00, 7);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('LUX',  'Luxury',    'Premium luxury vehicles',                   150.00,  900.00, 3000.00,  700.00, 5);
INSERT INTO crs_vehicle_categories (category_code, category_name, description, daily_rate, weekly_rate, monthly_rate, deposit_amount, max_passengers)
VALUES ('VAN',  'Minivan',   'Minivans for large groups or families',      85.00,  510.00, 1700.00,  350.00, 8);

-- VEHICLES
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (1, 1, '1HGCM82633A123001', 'NY-ECO-001', 'Toyota', 'Yaris',   2022, 'White',  12000, 'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (1, 2, '1HGCM82633A123002', 'NY-ECO-002', 'Honda',  'Fit',     2023, 'Silver', 8500,  'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (2, 1, '1HGCM82633A123003', 'NY-COM-001', 'Toyota', 'Corolla', 2023, 'Black',  15000, 'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (2, 3, '1HGCM82633A123004', 'NY-COM-002', 'Honda',  'Civic',   2022, 'Blue',   22000, 'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (3, 1, '1HGCM82633A123005', 'NY-MID-001', 'Toyota', 'Camry',   2023, 'Gray',   9000,  'Hybrid');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (3, 2, '1HGCM82633A123006', 'NY-MID-002', 'Honda',  'Accord',  2022, 'White',  18000, 'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (5, 1, '1HGCM82633A123007', 'NY-SUV-001', 'Toyota', 'RAV4',    2023, 'Red',    5500,  'Hybrid');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (5, 4, '1HGCM82633A123008', 'CA-SUV-001', 'Ford',   'Explorer', 2022,'Black',  27000, 'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (6, 2, '1HGCM82633A123009', 'NY-LUX-001', 'BMW',    '5 Series',2023, 'Navy',   6000,  'Gasoline');
INSERT INTO crs_vehicles (category_id, location_id, vin, plate_number, make, model, model_year, color, mileage, fuel_type)
VALUES (6, 5, '1HGCM82633A123010', 'CA-LUX-001', 'Mercedes','E-Class',2023, 'Silver', 4200,  'Gasoline');

-- CUSTOMERS
INSERT INTO crs_customers (first_name, last_name, email, phone, date_of_birth, license_number, license_expiry, license_country, address, city, state, postal_code)
VALUES ('John',    'Smith',    'john.smith@email.com',    '917-555-0101', DATE '1985-03-15', 'DL-NY-123456', DATE '2027-03-15', 'USA', '42 Oak St',      'New York',    'NY', '10002');
INSERT INTO crs_customers (first_name, last_name, email, phone, date_of_birth, license_number, license_expiry, license_country, address, city, state, postal_code)
VALUES ('Emily',   'Johnson',  'emily.j@email.com',       '646-555-0202', DATE '1990-07-22', 'DL-NY-234567', DATE '2026-07-22', 'USA', '88 Pine Ave',    'New York',    'NY', '10003');
INSERT INTO crs_customers (first_name, last_name, email, phone, date_of_birth, license_number, license_expiry, license_country, address, city, state, postal_code)
VALUES ('Michael', 'Williams', 'mike.w@email.com',        '718-555-0303', DATE '1978-11-08', 'DL-NY-345678', DATE '2028-11-08', 'USA', '15 Elm Road',    'Brooklyn',    'NY', '11201');
INSERT INTO crs_customers (first_name, last_name, email, phone, date_of_birth, license_number, license_expiry, license_country, address, city, state, postal_code)
VALUES ('Sarah',   'Brown',    'sarah.brown@email.com',   '310-555-0404', DATE '1992-05-30', 'DL-CA-456789', DATE '2027-05-30', 'USA', '200 Willow Blvd','Los Angeles', 'CA', '90001');
INSERT INTO crs_customers (first_name, last_name, email, phone, date_of_birth, license_number, license_expiry, license_country, address, city, state, postal_code)
VALUES ('David',   'Garcia',   'david.garcia@email.com',  '323-555-0505', DATE '1983-09-14', 'DL-CA-567890', DATE '2026-09-14', 'USA', '77 Maple Lane',  'Los Angeles', 'CA', '90010');

-- RENTALS
INSERT INTO crs_rentals (customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
    rental_start_dt, rental_end_dt, agreed_daily_rate, total_days, base_amount, total_amount, deposit_amount, status)
VALUES (1001, 3, 1, 1, DATE '2026-03-01', DATE '2026-03-05', 45.00, 4,  180.00, 195.30,  200.00, 'COMPLETED');
INSERT INTO crs_rentals (customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
    rental_start_dt, rental_end_dt, agreed_daily_rate, total_days, base_amount, total_amount, deposit_amount, status)
VALUES (1002, 7, 1, 2, DATE '2026-03-10', DATE '2026-03-15', 95.00, 5,  475.00, 515.38,  400.00, 'COMPLETED');
INSERT INTO crs_rentals (customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
    rental_start_dt, rental_end_dt, agreed_daily_rate, total_days, base_amount, total_amount, deposit_amount, status)
VALUES (1003, 9, 2, 2, DATE '2026-04-02', DATE '2026-04-06', 150.00, 4, 600.00, 651.00,  700.00, 'ACTIVE');
INSERT INTO crs_rentals (customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
    rental_start_dt, rental_end_dt, agreed_daily_rate, total_days, base_amount, total_amount, deposit_amount, status)
VALUES (1004, 8, 5, 5, DATE '2026-04-05', DATE '2026-04-12', 95.00, 7,  665.00, 721.53,  400.00, 'RESERVED');
INSERT INTO crs_rentals (customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
    rental_start_dt, rental_end_dt, agreed_daily_rate, total_days, base_amount, total_amount, deposit_amount, status)
VALUES (1005, 10, 5, 4, DATE '2026-04-08', DATE '2026-04-10', 150.00, 2, 300.00, 325.50,  700.00, 'RESERVED');

-- PAYMENTS
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10001, DATE '2026-03-01', 200.00, 'CHARGE', 'CREDIT_CARD', 'CC-REF-001', 'Y');
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10001, DATE '2026-03-05', 195.30, 'CHARGE', 'CREDIT_CARD', 'CC-REF-002', 'N');
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10001, DATE '2026-03-06', 200.00, 'REFUND',  'CREDIT_CARD', 'CC-REF-003', 'Y');
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10002, DATE '2026-03-10', 400.00, 'CHARGE', 'CREDIT_CARD', 'CC-REF-004', 'Y');
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10002, DATE '2026-03-15', 515.38, 'CHARGE', 'CREDIT_CARD', 'CC-REF-005', 'N');
INSERT INTO crs_payments (rental_id, payment_date, amount, payment_type, payment_method, reference_no, is_deposit)
VALUES (10003, DATE '2026-04-02', 700.00, 'CHARGE', 'CREDIT_CARD', 'CC-REF-006', 'Y');

COMMIT;
