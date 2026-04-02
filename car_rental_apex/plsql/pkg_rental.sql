-- ============================================================
-- Car Rental System (CRS) - Rental Package
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_rental AS

    -- Create a new rental reservation
    FUNCTION create_reservation (
        p_customer_id         IN crs_rentals.customer_id%TYPE,
        p_vehicle_id          IN crs_rentals.vehicle_id%TYPE,
        p_pickup_location_id  IN crs_rentals.pickup_location_id%TYPE,
        p_dropoff_location_id IN crs_rentals.dropoff_location_id%TYPE,
        p_start_dt            IN crs_rentals.rental_start_dt%TYPE,
        p_end_dt              IN crs_rentals.rental_end_dt%TYPE,
        p_discount_pct        IN crs_rentals.discount_pct%TYPE DEFAULT 0,
        p_created_by          IN crs_rentals.created_by%TYPE   DEFAULT USER
    ) RETURN crs_rentals.rental_id%TYPE;

    -- Activate a reservation (customer picks up vehicle)
    PROCEDURE activate_rental (
        p_rental_id   IN crs_rentals.rental_id%TYPE,
        p_modified_by IN VARCHAR2 DEFAULT USER
    );

    -- Complete a rental (customer returns vehicle)
    PROCEDURE complete_rental (
        p_rental_id        IN crs_rentals.rental_id%TYPE,
        p_return_dt        IN DATE DEFAULT SYSDATE,
        p_additional_chrgs IN crs_rentals.additional_charges%TYPE DEFAULT 0,
        p_modified_by      IN VARCHAR2 DEFAULT USER
    );

    -- Cancel a reservation
    PROCEDURE cancel_rental (
        p_rental_id   IN crs_rentals.rental_id%TYPE,
        p_reason      IN VARCHAR2 DEFAULT NULL,
        p_modified_by IN VARCHAR2 DEFAULT USER
    );

    -- Check vehicle availability for a date range
    FUNCTION is_vehicle_available (
        p_vehicle_id IN crs_vehicles.vehicle_id%TYPE,
        p_start_dt   IN DATE,
        p_end_dt     IN DATE,
        p_exclude_rental_id IN crs_rentals.rental_id%TYPE DEFAULT NULL
    ) RETURN BOOLEAN;

    -- Calculate rental cost
    FUNCTION calculate_cost (
        p_category_id  IN crs_vehicle_categories.category_id%TYPE,
        p_start_dt     IN DATE,
        p_end_dt       IN DATE,
        p_discount_pct IN NUMBER DEFAULT 0
    ) RETURN NUMBER;

END pkg_rental;
/

CREATE OR REPLACE PACKAGE BODY pkg_rental AS

    FUNCTION create_reservation (
        p_customer_id         IN crs_rentals.customer_id%TYPE,
        p_vehicle_id          IN crs_rentals.vehicle_id%TYPE,
        p_pickup_location_id  IN crs_rentals.pickup_location_id%TYPE,
        p_dropoff_location_id IN crs_rentals.dropoff_location_id%TYPE,
        p_start_dt            IN crs_rentals.rental_start_dt%TYPE,
        p_end_dt              IN crs_rentals.rental_end_dt%TYPE,
        p_discount_pct        IN crs_rentals.discount_pct%TYPE DEFAULT 0,
        p_created_by          IN crs_rentals.created_by%TYPE   DEFAULT USER
    ) RETURN crs_rentals.rental_id%TYPE IS

        v_rental_id     crs_rentals.rental_id%TYPE;
        v_category_id   crs_vehicle_categories.category_id%TYPE;
        v_daily_rate    crs_vehicle_categories.daily_rate%TYPE;
        v_deposit       crs_vehicle_categories.deposit_amount%TYPE;
        v_total_days    NUMBER;
        v_base_amount   NUMBER;
        v_tax_pct       CONSTANT NUMBER := 8.5;
        v_total_amount  NUMBER;
        v_blacklisted   crs_customers.blacklisted%TYPE;
        v_lic_expiry    crs_customers.license_expiry%TYPE;

    BEGIN
        -- Validate customer
        SELECT blacklisted, license_expiry
          INTO v_blacklisted, v_lic_expiry
          FROM crs_customers
         WHERE customer_id = p_customer_id;

        IF v_blacklisted = 'Y' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Customer is blacklisted and cannot rent vehicles.');
        END IF;

        IF v_lic_expiry < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20002, 'Customer driving license has expired.');
        END IF;

        -- Validate vehicle availability
        IF NOT is_vehicle_available(p_vehicle_id, p_start_dt, p_end_dt) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Vehicle is not available for the selected dates.');
        END IF;

        -- Get category and rate
        SELECT vc.category_id, vc.daily_rate, vc.deposit_amount
          INTO v_category_id, v_daily_rate, v_deposit
          FROM crs_vehicles v
          JOIN crs_vehicle_categories vc ON v.category_id = vc.category_id
         WHERE v.vehicle_id = p_vehicle_id;

        -- Calculate amounts
        v_total_days   := GREATEST(1, TRUNC(p_end_dt) - TRUNC(p_start_dt));
        v_base_amount  := v_total_days * v_daily_rate;
        v_base_amount  := v_base_amount * (1 - NVL(p_discount_pct, 0) / 100);
        v_total_amount := v_base_amount * (1 + v_tax_pct / 100);

        -- Insert rental
        INSERT INTO crs_rentals (
            customer_id, vehicle_id,
            pickup_location_id, dropoff_location_id,
            rental_start_dt, rental_end_dt,
            agreed_daily_rate, total_days,
            base_amount, discount_pct, tax_pct,
            total_amount, deposit_amount,
            status, created_by
        ) VALUES (
            p_customer_id, p_vehicle_id,
            p_pickup_location_id, p_dropoff_location_id,
            p_start_dt, p_end_dt,
            v_daily_rate, v_total_days,
            v_base_amount, p_discount_pct, v_tax_pct,
            v_total_amount, v_deposit,
            'RESERVED', p_created_by
        ) RETURNING rental_id INTO v_rental_id;

        COMMIT;
        RETURN v_rental_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_reservation;

    -- --------------------------------------------------------
    PROCEDURE activate_rental (
        p_rental_id   IN crs_rentals.rental_id%TYPE,
        p_modified_by IN VARCHAR2 DEFAULT USER
    ) IS
        v_vehicle_id crs_vehicles.vehicle_id%TYPE;
        v_status     crs_rentals.status%TYPE;
    BEGIN
        SELECT vehicle_id, status
          INTO v_vehicle_id, v_status
          FROM crs_rentals
         WHERE rental_id = p_rental_id
           FOR UPDATE;

        IF v_status != 'RESERVED' THEN
            RAISE_APPLICATION_ERROR(-20010, 'Only RESERVED rentals can be activated. Current status: ' || v_status);
        END IF;

        UPDATE crs_rentals
           SET status     = 'ACTIVE',
               updated_at = SYSTIMESTAMP
         WHERE rental_id = p_rental_id;

        UPDATE crs_vehicles
           SET status     = 'RENTED',
               updated_at = SYSTIMESTAMP
         WHERE vehicle_id = v_vehicle_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END activate_rental;

    -- --------------------------------------------------------
    PROCEDURE complete_rental (
        p_rental_id        IN crs_rentals.rental_id%TYPE,
        p_return_dt        IN DATE DEFAULT SYSDATE,
        p_additional_chrgs IN crs_rentals.additional_charges%TYPE DEFAULT 0,
        p_modified_by      IN VARCHAR2 DEFAULT USER
    ) IS
        v_vehicle_id    crs_vehicles.vehicle_id%TYPE;
        v_location_id   crs_locations.location_id%TYPE;
        v_status        crs_rentals.status%TYPE;
        v_total_amount  crs_rentals.total_amount%TYPE;
        v_tax_pct       crs_rentals.tax_pct%TYPE;
    BEGIN
        SELECT vehicle_id, dropoff_location_id, status, total_amount, tax_pct
          INTO v_vehicle_id, v_location_id, v_status, v_total_amount, v_tax_pct
          FROM crs_rentals
         WHERE rental_id = p_rental_id
           FOR UPDATE;

        IF v_status != 'ACTIVE' THEN
            RAISE_APPLICATION_ERROR(-20011, 'Only ACTIVE rentals can be completed. Current status: ' || v_status);
        END IF;

        -- Add additional charges (taxes on top)
        IF p_additional_chrgs > 0 THEN
            v_total_amount := v_total_amount + (p_additional_chrgs * (1 + v_tax_pct / 100));
        END IF;

        UPDATE crs_rentals
           SET status             = 'COMPLETED',
               actual_return_dt   = p_return_dt,
               additional_charges = NVL(p_additional_chrgs, 0),
               total_amount       = v_total_amount,
               updated_at         = SYSTIMESTAMP
         WHERE rental_id = p_rental_id;

        UPDATE crs_vehicles
           SET status      = 'AVAILABLE',
               location_id = v_location_id,
               updated_at  = SYSTIMESTAMP
         WHERE vehicle_id = v_vehicle_id;

        -- Award loyalty points (1 point per dollar)
        UPDATE crs_customers c
           SET loyalty_points = loyalty_points + FLOOR(v_total_amount),
               updated_at     = SYSTIMESTAMP
         WHERE customer_id = (SELECT customer_id FROM crs_rentals WHERE rental_id = p_rental_id);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END complete_rental;

    -- --------------------------------------------------------
    PROCEDURE cancel_rental (
        p_rental_id   IN crs_rentals.rental_id%TYPE,
        p_reason      IN VARCHAR2 DEFAULT NULL,
        p_modified_by IN VARCHAR2 DEFAULT USER
    ) IS
        v_status crs_rentals.status%TYPE;
    BEGIN
        SELECT status INTO v_status
          FROM crs_rentals
         WHERE rental_id = p_rental_id
           FOR UPDATE;

        IF v_status NOT IN ('RESERVED') THEN
            RAISE_APPLICATION_ERROR(-20012, 'Only RESERVED rentals can be cancelled. Current status: ' || v_status);
        END IF;

        UPDATE crs_rentals
           SET status     = 'CANCELLED',
               notes      = NVL(p_reason, notes),
               updated_at = SYSTIMESTAMP
         WHERE rental_id = p_rental_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END cancel_rental;

    -- --------------------------------------------------------
    FUNCTION is_vehicle_available (
        p_vehicle_id        IN crs_vehicles.vehicle_id%TYPE,
        p_start_dt          IN DATE,
        p_end_dt            IN DATE,
        p_exclude_rental_id IN crs_rentals.rental_id%TYPE DEFAULT NULL
    ) RETURN BOOLEAN IS
        v_count     NUMBER;
        v_status    crs_vehicles.status%TYPE;
    BEGIN
        SELECT status INTO v_status
          FROM crs_vehicles
         WHERE vehicle_id = p_vehicle_id;

        IF v_status NOT IN ('AVAILABLE', 'RENTED') THEN
            RETURN FALSE;
        END IF;

        SELECT COUNT(*)
          INTO v_count
          FROM crs_rentals
         WHERE vehicle_id  = p_vehicle_id
           AND status      IN ('RESERVED', 'ACTIVE')
           AND rental_id   != NVL(p_exclude_rental_id, -1)
           AND rental_start_dt <= p_end_dt
           AND rental_end_dt   >= p_start_dt;

        RETURN v_count = 0;
    END is_vehicle_available;

    -- --------------------------------------------------------
    FUNCTION calculate_cost (
        p_category_id  IN crs_vehicle_categories.category_id%TYPE,
        p_start_dt     IN DATE,
        p_end_dt       IN DATE,
        p_discount_pct IN NUMBER DEFAULT 0
    ) RETURN NUMBER IS
        v_daily_rate    NUMBER;
        v_weekly_rate   NUMBER;
        v_total_days    NUMBER;
        v_base_amount   NUMBER;
        v_tax_pct       CONSTANT NUMBER := 8.5;
    BEGIN
        SELECT daily_rate, NVL(weekly_rate, daily_rate * 7)
          INTO v_daily_rate, v_weekly_rate
          FROM crs_vehicle_categories
         WHERE category_id = p_category_id;

        v_total_days := GREATEST(1, TRUNC(p_end_dt) - TRUNC(p_start_dt));

        IF v_total_days >= 7 THEN
            v_base_amount := FLOOR(v_total_days / 7) * v_weekly_rate
                           + MOD(v_total_days, 7)    * v_daily_rate;
        ELSE
            v_base_amount := v_total_days * v_daily_rate;
        END IF;

        v_base_amount := v_base_amount * (1 - NVL(p_discount_pct, 0) / 100);
        RETURN ROUND(v_base_amount * (1 + v_tax_pct / 100), 2);
    END calculate_cost;

END pkg_rental;
/
