-- ============================================================
-- Car Rental System (CRS) - Vehicle Management Package
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_vehicle AS

    -- Add a new vehicle
    FUNCTION add_vehicle (
        p_category_id   IN crs_vehicles.category_id%TYPE,
        p_location_id   IN crs_vehicles.location_id%TYPE,
        p_vin           IN crs_vehicles.vin%TYPE,
        p_plate_number  IN crs_vehicles.plate_number%TYPE,
        p_make          IN crs_vehicles.make%TYPE,
        p_model         IN crs_vehicles.model%TYPE,
        p_model_year    IN crs_vehicles.model_year%TYPE,
        p_color         IN crs_vehicles.color%TYPE         DEFAULT NULL,
        p_fuel_type     IN crs_vehicles.fuel_type%TYPE     DEFAULT 'Gasoline',
        p_transmission  IN crs_vehicles.transmission%TYPE  DEFAULT 'Automatic'
    ) RETURN crs_vehicles.vehicle_id%TYPE;

    -- Schedule vehicle for maintenance
    PROCEDURE schedule_maintenance (
        p_vehicle_id    IN crs_vehicles.vehicle_id%TYPE,
        p_service_type  IN crs_maintenance.service_type%TYPE,
        p_service_date  IN crs_maintenance.service_date%TYPE DEFAULT SYSDATE,
        p_description   IN crs_maintenance.description%TYPE  DEFAULT NULL,
        p_technician    IN crs_maintenance.technician%TYPE   DEFAULT NULL
    );

    -- Complete maintenance and return vehicle to available
    PROCEDURE complete_maintenance (
        p_maintenance_id IN crs_maintenance.maintenance_id%TYPE,
        p_cost           IN crs_maintenance.cost%TYPE           DEFAULT 0,
        p_mileage        IN crs_maintenance.mileage_at_svc%TYPE DEFAULT NULL,
        p_next_svc_dt    IN crs_maintenance.next_service_dt%TYPE DEFAULT NULL
    );

    -- Transfer vehicle to another location
    PROCEDURE transfer_vehicle (
        p_vehicle_id    IN crs_vehicles.vehicle_id%TYPE,
        p_new_location  IN crs_vehicles.location_id%TYPE
    );

    -- Retire a vehicle from the fleet
    PROCEDURE retire_vehicle (
        p_vehicle_id IN crs_vehicles.vehicle_id%TYPE,
        p_reason     IN VARCHAR2 DEFAULT NULL
    );

    -- Get available vehicles for a date range and category
    FUNCTION get_available_vehicles (
        p_category_id IN crs_vehicle_categories.category_id%TYPE DEFAULT NULL,
        p_location_id IN crs_locations.location_id%TYPE          DEFAULT NULL,
        p_start_dt    IN DATE                                     DEFAULT SYSDATE,
        p_end_dt      IN DATE                                     DEFAULT SYSDATE + 1
    ) RETURN SYS_REFCURSOR;

END pkg_vehicle;
/

CREATE OR REPLACE PACKAGE BODY pkg_vehicle AS

    FUNCTION add_vehicle (
        p_category_id   IN crs_vehicles.category_id%TYPE,
        p_location_id   IN crs_vehicles.location_id%TYPE,
        p_vin           IN crs_vehicles.vin%TYPE,
        p_plate_number  IN crs_vehicles.plate_number%TYPE,
        p_make          IN crs_vehicles.make%TYPE,
        p_model         IN crs_vehicles.model%TYPE,
        p_model_year    IN crs_vehicles.model_year%TYPE,
        p_color         IN crs_vehicles.color%TYPE         DEFAULT NULL,
        p_fuel_type     IN crs_vehicles.fuel_type%TYPE     DEFAULT 'Gasoline',
        p_transmission  IN crs_vehicles.transmission%TYPE  DEFAULT 'Automatic'
    ) RETURN crs_vehicles.vehicle_id%TYPE IS
        v_vehicle_id crs_vehicles.vehicle_id%TYPE;
    BEGIN
        INSERT INTO crs_vehicles (
            category_id, location_id, vin, plate_number,
            make, model, model_year, color, fuel_type, transmission
        ) VALUES (
            p_category_id, p_location_id, p_vin, p_plate_number,
            p_make, p_model, p_model_year, p_color, p_fuel_type, p_transmission
        ) RETURNING vehicle_id INTO v_vehicle_id;

        COMMIT;
        RETURN v_vehicle_id;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_vehicle;

    -- --------------------------------------------------------
    PROCEDURE schedule_maintenance (
        p_vehicle_id    IN crs_vehicles.vehicle_id%TYPE,
        p_service_type  IN crs_maintenance.service_type%TYPE,
        p_service_date  IN crs_maintenance.service_date%TYPE DEFAULT SYSDATE,
        p_description   IN crs_maintenance.description%TYPE  DEFAULT NULL,
        p_technician    IN crs_maintenance.technician%TYPE   DEFAULT NULL
    ) IS
        v_status crs_vehicles.status%TYPE;
    BEGIN
        SELECT status INTO v_status
          FROM crs_vehicles
         WHERE vehicle_id = p_vehicle_id
           FOR UPDATE;

        IF v_status = 'RENTED' THEN
            RAISE_APPLICATION_ERROR(-20020, 'Cannot schedule maintenance for a vehicle that is currently rented.');
        END IF;

        INSERT INTO crs_maintenance (vehicle_id, service_date, service_type, description, technician, status)
        VALUES (p_vehicle_id, p_service_date, p_service_type, p_description, p_technician, 'SCHEDULED');

        UPDATE crs_vehicles
           SET status     = 'MAINTENANCE',
               updated_at = SYSTIMESTAMP
         WHERE vehicle_id = p_vehicle_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END schedule_maintenance;

    -- --------------------------------------------------------
    PROCEDURE complete_maintenance (
        p_maintenance_id IN crs_maintenance.maintenance_id%TYPE,
        p_cost           IN crs_maintenance.cost%TYPE            DEFAULT 0,
        p_mileage        IN crs_maintenance.mileage_at_svc%TYPE  DEFAULT NULL,
        p_next_svc_dt    IN crs_maintenance.next_service_dt%TYPE DEFAULT NULL
    ) IS
        v_vehicle_id crs_vehicles.vehicle_id%TYPE;
    BEGIN
        UPDATE crs_maintenance
           SET status          = 'COMPLETED',
               cost            = p_cost,
               mileage_at_svc  = p_mileage,
               next_service_dt = p_next_svc_dt
         WHERE maintenance_id = p_maintenance_id
        RETURNING vehicle_id INTO v_vehicle_id;

        UPDATE crs_vehicles
           SET status          = 'AVAILABLE',
               last_service_dt = SYSDATE,
               mileage         = NVL(p_mileage, mileage),
               updated_at      = SYSTIMESTAMP
         WHERE vehicle_id = v_vehicle_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END complete_maintenance;

    -- --------------------------------------------------------
    PROCEDURE transfer_vehicle (
        p_vehicle_id    IN crs_vehicles.vehicle_id%TYPE,
        p_new_location  IN crs_vehicles.location_id%TYPE
    ) IS
    BEGIN
        UPDATE crs_vehicles
           SET location_id = p_new_location,
               updated_at  = SYSTIMESTAMP
         WHERE vehicle_id = p_vehicle_id
           AND status      = 'AVAILABLE';

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20030, 'Vehicle not found or not in AVAILABLE status for transfer.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END transfer_vehicle;

    -- --------------------------------------------------------
    PROCEDURE retire_vehicle (
        p_vehicle_id IN crs_vehicles.vehicle_id%TYPE,
        p_reason     IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        UPDATE crs_vehicles
           SET status     = 'RETIRED',
               notes      = NVL(p_reason, notes),
               updated_at = SYSTIMESTAMP
         WHERE vehicle_id = p_vehicle_id
           AND status     != 'RENTED';

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'Vehicle not found or is currently rented.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END retire_vehicle;

    -- --------------------------------------------------------
    FUNCTION get_available_vehicles (
        p_category_id IN crs_vehicle_categories.category_id%TYPE DEFAULT NULL,
        p_location_id IN crs_locations.location_id%TYPE          DEFAULT NULL,
        p_start_dt    IN DATE                                     DEFAULT SYSDATE,
        p_end_dt      IN DATE                                     DEFAULT SYSDATE + 1
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT v.vehicle_id,
                   v.make || ' ' || v.model || ' (' || v.model_year || ')' AS vehicle_name,
                   v.plate_number,
                   v.color,
                   v.fuel_type,
                   v.transmission,
                   v.mileage,
                   vc.category_name,
                   vc.daily_rate,
                   l.location_name
              FROM crs_vehicles v
              JOIN crs_vehicle_categories vc ON v.category_id = vc.category_id
              JOIN crs_locations           l  ON v.location_id = l.location_id
             WHERE v.status = 'AVAILABLE'
               AND (p_category_id IS NULL OR v.category_id = p_category_id)
               AND (p_location_id IS NULL OR v.location_id = p_location_id)
               AND NOT EXISTS (
                    SELECT 1 FROM crs_rentals r
                     WHERE r.vehicle_id  = v.vehicle_id
                       AND r.status      IN ('RESERVED', 'ACTIVE')
                       AND r.rental_start_dt <= p_end_dt
                       AND r.rental_end_dt   >= p_start_dt
                    )
             ORDER BY vc.daily_rate, v.make, v.model;

        RETURN v_cursor;
    END get_available_vehicles;

END pkg_vehicle;
/
