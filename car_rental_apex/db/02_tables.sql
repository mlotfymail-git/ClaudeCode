-- ============================================================
-- Car Rental System (CRS) - Tables
-- ============================================================

-- ------------------------------------------------------------
-- LOCATIONS
-- ------------------------------------------------------------
CREATE TABLE crs_locations (
    location_id     NUMBER          DEFAULT seq_location_id.NEXTVAL PRIMARY KEY,
    location_name   VARCHAR2(100)   NOT NULL,
    address         VARCHAR2(200)   NOT NULL,
    city            VARCHAR2(50)    NOT NULL,
    state           VARCHAR2(50),
    country         VARCHAR2(50)    DEFAULT 'USA' NOT NULL,
    postal_code     VARCHAR2(20),
    phone           VARCHAR2(20),
    email           VARCHAR2(100),
    is_active       CHAR(1)         DEFAULT 'Y' NOT NULL,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_loc_active CHECK (is_active IN ('Y', 'N'))
);

-- ------------------------------------------------------------
-- VEHICLE CATEGORIES
-- ------------------------------------------------------------
CREATE TABLE crs_vehicle_categories (
    category_id     NUMBER          DEFAULT seq_category_id.NEXTVAL PRIMARY KEY,
    category_code   VARCHAR2(10)    NOT NULL,
    category_name   VARCHAR2(50)    NOT NULL,
    description     VARCHAR2(255),
    daily_rate      NUMBER(10,2)    NOT NULL,
    weekly_rate     NUMBER(10,2),
    monthly_rate    NUMBER(10,2),
    deposit_amount  NUMBER(10,2)    DEFAULT 200 NOT NULL,
    max_passengers  NUMBER(2)       DEFAULT 5,
    is_active       CHAR(1)         DEFAULT 'Y' NOT NULL,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT uq_cat_code UNIQUE (category_code),
    CONSTRAINT chk_cat_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_daily_rate CHECK (daily_rate > 0)
);

-- ------------------------------------------------------------
-- VEHICLES
-- ------------------------------------------------------------
CREATE TABLE crs_vehicles (
    vehicle_id      NUMBER          DEFAULT seq_vehicle_id.NEXTVAL PRIMARY KEY,
    category_id     NUMBER          NOT NULL,
    location_id     NUMBER          NOT NULL,
    vin             VARCHAR2(17)    NOT NULL,
    plate_number    VARCHAR2(20)    NOT NULL,
    make            VARCHAR2(50)    NOT NULL,
    model           VARCHAR2(50)    NOT NULL,
    model_year      NUMBER(4)       NOT NULL,
    color           VARCHAR2(30),
    mileage         NUMBER(10)      DEFAULT 0 NOT NULL,
    fuel_type       VARCHAR2(20)    DEFAULT 'Gasoline' NOT NULL,
    transmission    VARCHAR2(20)    DEFAULT 'Automatic' NOT NULL,
    status          VARCHAR2(20)    DEFAULT 'AVAILABLE' NOT NULL,
    last_service_dt DATE,
    notes           VARCHAR2(500),
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT uq_vehicle_vin   UNIQUE (vin),
    CONSTRAINT uq_vehicle_plate UNIQUE (plate_number),
    CONSTRAINT fk_vehicle_cat   FOREIGN KEY (category_id)  REFERENCES crs_vehicle_categories(category_id),
    CONSTRAINT fk_vehicle_loc   FOREIGN KEY (location_id)  REFERENCES crs_locations(location_id),
    CONSTRAINT chk_vehicle_status CHECK (status IN ('AVAILABLE','RENTED','MAINTENANCE','RETIRED')),
    CONSTRAINT chk_fuel_type    CHECK (fuel_type IN ('Gasoline','Diesel','Hybrid','Electric')),
    CONSTRAINT chk_transmission CHECK (transmission IN ('Automatic','Manual'))
);

-- ------------------------------------------------------------
-- CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE crs_customers (
    customer_id         NUMBER          DEFAULT seq_customer_id.NEXTVAL PRIMARY KEY,
    first_name          VARCHAR2(50)    NOT NULL,
    last_name           VARCHAR2(50)    NOT NULL,
    email               VARCHAR2(100)   NOT NULL,
    phone               VARCHAR2(20),
    date_of_birth       DATE,
    license_number      VARCHAR2(30)    NOT NULL,
    license_expiry      DATE            NOT NULL,
    license_country     VARCHAR2(50)    DEFAULT 'USA',
    address             VARCHAR2(200),
    city                VARCHAR2(50),
    state               VARCHAR2(50),
    postal_code         VARCHAR2(20),
    country             VARCHAR2(50)    DEFAULT 'USA',
    loyalty_points      NUMBER(10)      DEFAULT 0 NOT NULL,
    customer_since      DATE            DEFAULT SYSDATE NOT NULL,
    blacklisted         CHAR(1)         DEFAULT 'N' NOT NULL,
    notes               VARCHAR2(500),
    created_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT uq_customer_email   UNIQUE (email),
    CONSTRAINT uq_customer_license UNIQUE (license_number),
    CONSTRAINT chk_cust_blacklist  CHECK (blacklisted IN ('Y', 'N')),
    CONSTRAINT chk_cust_dob        CHECK (date_of_birth < SYSDATE)
);

-- ------------------------------------------------------------
-- RENTALS
-- ------------------------------------------------------------
CREATE TABLE crs_rentals (
    rental_id           NUMBER          DEFAULT seq_rental_id.NEXTVAL PRIMARY KEY,
    customer_id         NUMBER          NOT NULL,
    vehicle_id          NUMBER          NOT NULL,
    pickup_location_id  NUMBER          NOT NULL,
    dropoff_location_id NUMBER          NOT NULL,
    rental_start_dt     DATE            NOT NULL,
    rental_end_dt       DATE            NOT NULL,
    actual_return_dt    DATE,
    agreed_daily_rate   NUMBER(10,2)    NOT NULL,
    total_days          NUMBER(5)       NOT NULL,
    base_amount         NUMBER(10,2)    NOT NULL,
    discount_pct        NUMBER(5,2)     DEFAULT 0,
    tax_pct             NUMBER(5,2)     DEFAULT 8.5,
    additional_charges  NUMBER(10,2)    DEFAULT 0,
    total_amount        NUMBER(10,2)    NOT NULL,
    deposit_amount      NUMBER(10,2)    NOT NULL,
    deposit_refunded    CHAR(1)         DEFAULT 'N',
    status              VARCHAR2(20)    DEFAULT 'RESERVED' NOT NULL,
    created_by          VARCHAR2(50),
    notes               VARCHAR2(500),
    created_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_rental_customer  FOREIGN KEY (customer_id)         REFERENCES crs_customers(customer_id),
    CONSTRAINT fk_rental_vehicle   FOREIGN KEY (vehicle_id)          REFERENCES crs_vehicles(vehicle_id),
    CONSTRAINT fk_rental_pickup    FOREIGN KEY (pickup_location_id)  REFERENCES crs_locations(location_id),
    CONSTRAINT fk_rental_dropoff   FOREIGN KEY (dropoff_location_id) REFERENCES crs_locations(location_id),
    CONSTRAINT chk_rental_status   CHECK (status IN ('RESERVED','ACTIVE','COMPLETED','CANCELLED')),
    CONSTRAINT chk_rental_dates    CHECK (rental_end_dt >= rental_start_dt),
    CONSTRAINT chk_deposit_refund  CHECK (deposit_refunded IN ('Y','N'))
);

-- ------------------------------------------------------------
-- PAYMENTS
-- ------------------------------------------------------------
CREATE TABLE crs_payments (
    payment_id      NUMBER          DEFAULT seq_payment_id.NEXTVAL PRIMARY KEY,
    rental_id       NUMBER          NOT NULL,
    payment_date    DATE            DEFAULT SYSDATE NOT NULL,
    amount          NUMBER(10,2)    NOT NULL,
    payment_type    VARCHAR2(20)    NOT NULL,
    payment_method  VARCHAR2(20)    NOT NULL,
    reference_no    VARCHAR2(100),
    is_deposit      CHAR(1)         DEFAULT 'N' NOT NULL,
    notes           VARCHAR2(255),
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_payment_rental   FOREIGN KEY (rental_id) REFERENCES crs_rentals(rental_id),
    CONSTRAINT chk_payment_type    CHECK (payment_type   IN ('CHARGE','REFUND')),
    CONSTRAINT chk_payment_method  CHECK (payment_method IN ('CASH','CREDIT_CARD','DEBIT_CARD','BANK_TRANSFER','ONLINE')),
    CONSTRAINT chk_payment_deposit CHECK (is_deposit IN ('Y','N')),
    CONSTRAINT chk_payment_amount  CHECK (amount > 0)
);

-- ------------------------------------------------------------
-- MAINTENANCE RECORDS
-- ------------------------------------------------------------
CREATE TABLE crs_maintenance (
    maintenance_id  NUMBER          DEFAULT seq_maintenance_id.NEXTVAL PRIMARY KEY,
    vehicle_id      NUMBER          NOT NULL,
    service_date    DATE            NOT NULL,
    service_type    VARCHAR2(50)    NOT NULL,
    description     VARCHAR2(500),
    cost            NUMBER(10,2),
    mileage_at_svc  NUMBER(10),
    technician      VARCHAR2(100),
    next_service_dt DATE,
    status          VARCHAR2(20)    DEFAULT 'COMPLETED' NOT NULL,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_maint_vehicle    FOREIGN KEY (vehicle_id) REFERENCES crs_vehicles(vehicle_id),
    CONSTRAINT chk_maint_status    CHECK (status IN ('SCHEDULED','IN_PROGRESS','COMPLETED'))
);
