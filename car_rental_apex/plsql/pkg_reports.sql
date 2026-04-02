-- ============================================================
-- Car Rental System (CRS) - Reports Package
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_reports AS

    -- Revenue summary by date range
    FUNCTION get_revenue_summary (
        p_start_dt    IN DATE DEFAULT TRUNC(SYSDATE, 'MM'),
        p_end_dt      IN DATE DEFAULT SYSDATE
    ) RETURN SYS_REFCURSOR;

    -- Active rentals report
    FUNCTION get_active_rentals RETURN SYS_REFCURSOR;

    -- Fleet utilization by category
    FUNCTION get_fleet_utilization (
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN SYS_REFCURSOR;

    -- Overdue rentals (not returned by expected date)
    FUNCTION get_overdue_rentals RETURN SYS_REFCURSOR;

    -- Top customers by revenue
    FUNCTION get_top_customers (
        p_limit IN NUMBER DEFAULT 10
    ) RETURN SYS_REFCURSOR;

END pkg_reports;
/

CREATE OR REPLACE PACKAGE BODY pkg_reports AS

    FUNCTION get_revenue_summary (
        p_start_dt IN DATE DEFAULT TRUNC(SYSDATE, 'MM'),
        p_end_dt   IN DATE DEFAULT SYSDATE
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                TO_CHAR(p.payment_date, 'YYYY-MM')         AS period,
                COUNT(DISTINCT r.rental_id)                 AS total_rentals,
                COUNT(DISTINCT r.customer_id)               AS unique_customers,
                SUM(CASE WHEN p.payment_type = 'CHARGE'
                          AND p.is_deposit   = 'N'
                    THEN p.amount ELSE 0 END)               AS rental_revenue,
                SUM(CASE WHEN p.payment_type = 'REFUND'
                    THEN p.amount ELSE 0 END)               AS total_refunds,
                SUM(CASE WHEN p.payment_type = 'CHARGE'
                          AND p.is_deposit   = 'N'
                    THEN p.amount ELSE 0 END)
                - SUM(CASE WHEN p.payment_type = 'REFUND'
                    THEN p.amount ELSE 0 END)               AS net_revenue
              FROM crs_payments p
              JOIN crs_rentals  r ON p.rental_id = r.rental_id
             WHERE p.payment_date BETWEEN p_start_dt AND p_end_dt
             GROUP BY TO_CHAR(p.payment_date, 'YYYY-MM')
             ORDER BY 1;

        RETURN v_cursor;
    END get_revenue_summary;

    -- --------------------------------------------------------
    FUNCTION get_active_rentals RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                r.rental_id,
                c.first_name || ' ' || c.last_name         AS customer_name,
                c.phone                                     AS customer_phone,
                v.make || ' ' || v.model                   AS vehicle,
                v.plate_number,
                vc.category_name,
                r.rental_start_dt,
                r.rental_end_dt,
                (r.rental_end_dt - TRUNC(SYSDATE))         AS days_remaining,
                pl.location_name                            AS pickup_location,
                dl.location_name                            AS dropoff_location,
                r.total_amount
              FROM crs_rentals            r
              JOIN crs_customers          c  ON r.customer_id         = c.customer_id
              JOIN crs_vehicles           v  ON r.vehicle_id          = v.vehicle_id
              JOIN crs_vehicle_categories vc ON v.category_id         = vc.category_id
              JOIN crs_locations          pl ON r.pickup_location_id  = pl.location_id
              JOIN crs_locations          dl ON r.dropoff_location_id = dl.location_id
             WHERE r.status = 'ACTIVE'
             ORDER BY r.rental_end_dt;

        RETURN v_cursor;
    END get_active_rentals;

    -- --------------------------------------------------------
    FUNCTION get_fleet_utilization (
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                vc.category_name,
                COUNT(v.vehicle_id)                                         AS total_vehicles,
                SUM(CASE WHEN v.status = 'AVAILABLE'   THEN 1 ELSE 0 END)  AS available,
                SUM(CASE WHEN v.status = 'RENTED'      THEN 1 ELSE 0 END)  AS rented,
                SUM(CASE WHEN v.status = 'MAINTENANCE' THEN 1 ELSE 0 END)  AS in_maintenance,
                SUM(CASE WHEN v.status = 'RETIRED'     THEN 1 ELSE 0 END)  AS retired,
                ROUND(
                    SUM(CASE WHEN v.status = 'RENTED' THEN 1 ELSE 0 END) * 100.0
                    / NULLIF(SUM(CASE WHEN v.status != 'RETIRED' THEN 1 ELSE 0 END), 0)
                , 1)                                                        AS utilization_pct
              FROM crs_vehicles           v
              JOIN crs_vehicle_categories vc ON v.category_id = vc.category_id
             GROUP BY vc.category_id, vc.category_name
             ORDER BY vc.category_name;

        RETURN v_cursor;
    END get_fleet_utilization;

    -- --------------------------------------------------------
    FUNCTION get_overdue_rentals RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                r.rental_id,
                c.first_name || ' ' || c.last_name  AS customer_name,
                c.phone                             AS customer_phone,
                c.email                             AS customer_email,
                v.plate_number,
                v.make || ' ' || v.model            AS vehicle,
                r.rental_end_dt                     AS due_date,
                TRUNC(SYSDATE) - r.rental_end_dt    AS days_overdue,
                r.total_amount
              FROM crs_rentals   r
              JOIN crs_customers c ON r.customer_id = c.customer_id
              JOIN crs_vehicles  v ON r.vehicle_id  = v.vehicle_id
             WHERE r.status         = 'ACTIVE'
               AND r.rental_end_dt  < TRUNC(SYSDATE)
             ORDER BY days_overdue DESC;

        RETURN v_cursor;
    END get_overdue_rentals;

    -- --------------------------------------------------------
    FUNCTION get_top_customers (
        p_limit IN NUMBER DEFAULT 10
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT *
              FROM (
                SELECT
                    c.customer_id,
                    c.first_name || ' ' || c.last_name  AS customer_name,
                    c.email,
                    c.loyalty_points,
                    COUNT(r.rental_id)                  AS total_rentals,
                    SUM(r.total_amount)                 AS total_spent,
                    MAX(r.rental_start_dt)              AS last_rental_dt
                  FROM crs_customers c
                  LEFT JOIN crs_rentals r
                    ON c.customer_id = r.customer_id
                   AND r.status IN ('COMPLETED', 'ACTIVE')
                 GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.loyalty_points
                 ORDER BY total_spent DESC NULLS LAST
                )
             WHERE ROWNUM <= p_limit;

        RETURN v_cursor;
    END get_top_customers;

END pkg_reports;
/
