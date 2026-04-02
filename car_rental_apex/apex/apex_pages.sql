-- ============================================================
-- Car Rental System (CRS) - APEX Application Setup Hints
-- ============================================================
-- This file documents the APEX pages and their data sources.
-- Use these queries in APEX Interactive Reports and Forms.
-- ============================================================

-- ============================================================
-- PAGE 1: DASHBOARD (Classic Report / Charts)
-- ============================================================

-- Widget: Today's Active Rentals Count
SELECT COUNT(*) AS active_rentals
  FROM crs_rentals
 WHERE status = 'ACTIVE';

-- Widget: Available Vehicles Count
SELECT COUNT(*) AS available_vehicles
  FROM crs_vehicles
 WHERE status = 'AVAILABLE';

-- Widget: Today's Revenue
SELECT NVL(SUM(amount), 0) AS todays_revenue
  FROM crs_payments
 WHERE payment_type = 'CHARGE'
   AND is_deposit   = 'N'
   AND TRUNC(payment_date) = TRUNC(SYSDATE);

-- Widget: Overdue Rentals
SELECT COUNT(*) AS overdue_count
  FROM crs_rentals
 WHERE status        = 'ACTIVE'
   AND rental_end_dt < TRUNC(SYSDATE);

-- Chart: Revenue by Month (last 6 months)
SELECT TO_CHAR(p.payment_date, 'Mon YYYY') AS month_label,
       SUM(p.amount)                        AS revenue
  FROM crs_payments p
 WHERE p.payment_type = 'CHARGE'
   AND p.is_deposit   = 'N'
   AND p.payment_date >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -5)
 GROUP BY TO_CHAR(p.payment_date, 'Mon YYYY'),
          TRUNC(p.payment_date, 'MM')
 ORDER BY TRUNC(p.payment_date, 'MM');

-- Chart: Fleet Status Breakdown (Pie)
SELECT status       AS label,
       COUNT(*)     AS value
  FROM crs_vehicles
 GROUP BY status;


-- ============================================================
-- PAGE 10: VEHICLE SEARCH / AVAILABILITY (Interactive Report)
-- ============================================================

SELECT v.vehicle_id,
       v.make || ' ' || v.model || ' (' || v.model_year || ')' AS vehicle_name,
       v.plate_number,
       v.color,
       v.fuel_type,
       v.transmission,
       v.mileage,
       vc.category_name,
       vc.daily_rate,
       l.location_name,
       v.status
  FROM crs_vehicles           v
  JOIN crs_vehicle_categories vc ON v.category_id = vc.category_id
  JOIN crs_locations           l ON v.location_id  = l.location_id
 WHERE (:P10_CATEGORY IS NULL OR vc.category_id = :P10_CATEGORY)
   AND (:P10_LOCATION IS NULL OR l.location_id  = :P10_LOCATION)
   AND (:P10_STATUS   IS NULL OR v.status        = :P10_STATUS)
 ORDER BY vc.daily_rate, v.make, v.model;


-- ============================================================
-- PAGE 20: CUSTOMERS (Interactive Report)
-- ============================================================

SELECT c.customer_id,
       c.first_name || ' ' || c.last_name  AS full_name,
       c.email,
       c.phone,
       c.license_number,
       c.license_expiry,
       c.loyalty_points,
       c.customer_since,
       c.blacklisted,
       COUNT(r.rental_id)                  AS total_rentals,
       NVL(SUM(r.total_amount), 0)         AS total_spent
  FROM crs_customers c
  LEFT JOIN crs_rentals r
    ON c.customer_id = r.customer_id
   AND r.status IN ('COMPLETED','ACTIVE')
 WHERE (:P20_SEARCH IS NULL
     OR UPPER(c.first_name || ' ' || c.last_name) LIKE '%' || UPPER(:P20_SEARCH) || '%'
     OR c.email          LIKE '%' || LOWER(:P20_SEARCH) || '%'
     OR c.license_number LIKE '%' || UPPER(:P20_SEARCH) || '%')
 GROUP BY c.customer_id, c.first_name, c.last_name,
          c.email, c.phone, c.license_number, c.license_expiry,
          c.loyalty_points, c.customer_since, c.blacklisted
 ORDER BY c.last_name, c.first_name;


-- ============================================================
-- PAGE 30: RENTALS (Interactive Report)
-- ============================================================

SELECT r.rental_id,
       c.first_name || ' ' || c.last_name          AS customer_name,
       v.make || ' ' || v.model                    AS vehicle,
       v.plate_number,
       vc.category_name,
       pl.location_name                            AS pickup_location,
       dl.location_name                            AS dropoff_location,
       r.rental_start_dt,
       r.rental_end_dt,
       r.actual_return_dt,
       r.total_days,
       r.agreed_daily_rate,
       r.total_amount,
       r.status,
       CASE WHEN r.status = 'ACTIVE' AND r.rental_end_dt < SYSDATE
            THEN 'Y' ELSE 'N' END                  AS is_overdue
  FROM crs_rentals            r
  JOIN crs_customers          c  ON r.customer_id         = c.customer_id
  JOIN crs_vehicles           v  ON r.vehicle_id          = v.vehicle_id
  JOIN crs_vehicle_categories vc ON v.category_id         = vc.category_id
  JOIN crs_locations          pl ON r.pickup_location_id  = pl.location_id
  JOIN crs_locations          dl ON r.dropoff_location_id = dl.location_id
 WHERE (:P30_STATUS     IS NULL OR r.status      = :P30_STATUS)
   AND (:P30_CUSTOMER   IS NULL OR r.customer_id = :P30_CUSTOMER)
   AND (:P30_DATE_FROM  IS NULL OR r.rental_start_dt >= TO_DATE(:P30_DATE_FROM,'YYYY-MM-DD'))
   AND (:P30_DATE_TO    IS NULL OR r.rental_end_dt   <= TO_DATE(:P30_DATE_TO,'YYYY-MM-DD'))
 ORDER BY r.rental_id DESC;


-- ============================================================
-- PAGE 40: PAYMENTS (Interactive Report)
-- ============================================================

SELECT p.payment_id,
       r.rental_id,
       c.first_name || ' ' || c.last_name  AS customer_name,
       p.payment_date,
       p.amount,
       p.payment_type,
       p.payment_method,
       p.reference_no,
       CASE p.is_deposit WHEN 'Y' THEN 'Deposit' ELSE 'Rental' END AS payment_for,
       p.notes
  FROM crs_payments  p
  JOIN crs_rentals   r ON p.rental_id   = r.rental_id
  JOIN crs_customers c ON r.customer_id = c.customer_id
 WHERE (:P40_RENTAL_ID IS NULL OR p.rental_id = :P40_RENTAL_ID)
   AND (:P40_DATE_FROM IS NULL OR p.payment_date >= TO_DATE(:P40_DATE_FROM,'YYYY-MM-DD'))
   AND (:P40_DATE_TO   IS NULL OR p.payment_date <= TO_DATE(:P40_DATE_TO,'YYYY-MM-DD'))
 ORDER BY p.payment_date DESC, p.payment_id DESC;


-- ============================================================
-- PAGE 50: MAINTENANCE (Interactive Report)
-- ============================================================

SELECT m.maintenance_id,
       v.make || ' ' || v.model  AS vehicle,
       v.plate_number,
       l.location_name,
       m.service_date,
       m.service_type,
       m.description,
       m.technician,
       m.cost,
       m.mileage_at_svc,
       m.next_service_dt,
       m.status
  FROM crs_maintenance m
  JOIN crs_vehicles    v ON m.vehicle_id  = v.vehicle_id
  JOIN crs_locations   l ON v.location_id = l.location_id
 WHERE (:P50_VEHICLE_ID IS NULL OR m.vehicle_id = :P50_VEHICLE_ID)
   AND (:P50_STATUS     IS NULL OR m.status     = :P50_STATUS)
 ORDER BY m.service_date DESC;
