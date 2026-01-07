WITH dummy AS (
    SELECT
        image_id,
        score,
        ROW_NUMBER() OVER (ORDER BY score DESC) AS sc_desc,
        ROW_NUMBER() OVER (ORDER BY score ASC)  AS sc_asc
    FROM unlabeled_image_predictions
),

positive_samples AS (
    SELECT
        image_id,
        1 AS weak_label
    FROM dummy
    WHERE sc_desc % 3 = 1
    ORDER BY sc_desc
    LIMIT 10000
),

negative_samples AS (
    SELECT
        image_id,
        0 AS weak_label
    FROM dummy
    WHERE sc_asc % 3 = 1
    ORDER BY sc_asc
    LIMIT 10000
)

SELECT image_id, weak_label
FROM (
    SELECT * FROM positive_samples
    UNION ALL
    SELECT * FROM negative_samples
) t
ORDER BY image_id;
