//Thought behind this approach: We have to order the images in increasing and decreasing order so instead of writing a subquerry
// inside positive and negative_samples i made a CTE named dummy which i can use below.Also ROW_NUMBER is used for assigning the numbers
// they will assign numbers like 1 for the highest score in the sc_desc and so-on and 1 for the lowest score in sc_asc and the count goes on..
WITH dummy AS (
    SELECT
        image_id,
        score,
        ROW_NUMBER() OVER (ORDER BY score DESC) AS sc_desc,
        ROW_NUMBER() OVER (ORDER BY score ASC)  AS sc_asc
    FROM unlabeled_image_predictions
),

// inside the dummy i wrote sc_desc and sc_asc this is for the score sorted in desc and asc order bcoz i will use it in
   //positive_samples and negative_samples.

positive_samples AS (
    SELECT
        image_id,
        1 AS weak_label
    FROM dummy
    WHERE sc_desc % 3 = 1
    ORDER BY sc_desc
    LIMIT 10000
),

//Here in both positive_samples and negatiVE_Samples i am doing mod by 3 bcoz we have to sample every third image.And also
    //we are making a separate column called weak_label bcoz we have to use it in the final answer.

negative_samples AS (
    SELECT
        image_id,
        0 AS weak_label
    FROM dummy
    WHERE sc_asc % 3 = 1
    ORDER BY sc_asc
    LIMIT 10000
)

// in the end i am doing UNION ALL bcoz it is fast and it will give total 20,000 rows 10K from each sample.

SELECT image_id, weak_label
FROM (
    SELECT * FROM positive_samples
    UNION ALL
    SELECT * FROM negative_samples
) t
ORDER BY image_id;
