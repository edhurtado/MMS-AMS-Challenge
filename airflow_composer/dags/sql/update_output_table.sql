WITH raw_sales AS (
    SELECT 
        sd.country,
        sd.sales_date,
        sd.outlet_id,
        sd.sales_value
    FROM sales_daily AS sd
    INNER JOIN products_info AS pi
        ON sd.brand = pi.brand
    WHERE NOT pi.is_own_brand
        AND sd.sales_date = CURRENT_DATE()
)

, countries_with_sales AS (
    SELECT DISTINCT
        country
    FROM sales_daily
    WHERE IFNULL(sales_value, 0) > 0 
)

, raw_outlets_info AS (
    SELECT
        oi.outlet_id,
        oi.outlet_name,
        oi.country,
        oi.region,
    FROM outlets_info AS oi
    INNER JOIN countries_with_sales AS cws
        ON oi.country = cws.country
)

SELECT
    rs.country,
    rs.sales_date,
    rs.outlet_id,
    roi.outlet_name,
    roi.region,
    rs.sales_value,
    rs.sales_value * ce.ex_loc_to_eur AS sales_value_eur
FROM raw_sales AS rs
LEFT JOIN raw_outlets_info AS roi
    ON rs.outlet_id = roi.outlet_id
    AND rs.country = roi.country
LEFT JOIN curr_exchange AS ce
    ON rs.country = ce.country
    AND rs.sales_date = ce.rate_date