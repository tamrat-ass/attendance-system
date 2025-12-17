-- ========================================
-- MK ATTENDANCE SYSTEM - PERFORMANCE OPTIMIZED 100K STUDENTS
-- ========================================
-- Optimized for maximum performance and minimal server load

-- Step 1: Prepare database for bulk insert
SET SESSION sql_mode = '';
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;
SET sql_log_bin = 0;

-- Step 2: Increase buffer sizes for better performance
SET SESSION bulk_insert_buffer_size = 256 * 1024 * 1024;
SET SESSION myisam_sort_buffer_size = 256 * 1024 * 1024;

-- Step 3: Create temporary table for number generation
CREATE TEMPORARY TABLE IF NOT EXISTS numbers (n INT PRIMARY KEY);

-- Generate numbers 1 to 100,000
INSERT INTO numbers (n) VALUES 
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
(91),(92),(93),(94),(95),(96),(97),(98),(99),(100);

-- Expand to 100,000 using cross join
INSERT INTO numbers (n)
SELECT a.n + (b.n-1)*100 + (c.n-1)*10000
FROM numbers a
CROSS JOIN numbers b
CROSS JOIN (SELECT n FROM numbers WHERE n <= 10) c
WHERE a.n + (b.n-1)*100 + (c.n-1)*10000 <= 100000
AND a.n + (b.n-1)*100 + (c.n-1)*10000 > 100;

-- Step 4: Bulk insert students
START TRANSACTION;

INSERT INTO students (full_name, phone, class)
SELECT 
    -- Generate realistic names
    CONCAT(
        ELT(((n-1) % 100) + 1,
            'Ahmed','Fatima','Mohamed','Sara','Omar','Aisha','Ali','Maryam','Hassan','Khadija',
            'Ibrahim','Zeinab','Yusuf','Amina','Khalid','Nour','Mahmoud','Layla','Tariq','Yasmin',
            'Abdullah','Mariam','Hamza','Salma','Karim','Dina','Sami','Rana','Fadi','Lina',
            'Nader','Maya','Rami','Hala','Samir','Nadia','Walid','Reem','Majid','Salam',
            'Bassam','Huda','Adel','Widad','Munir','Sawsan','Jamal','Suha','Fouad','Leila',
            'Khaled','Mona','Tamer','Noha','Sherif','Eman','Ashraf','Hanan','Mostafa','Ghada',
            'Amr','Dalia','Hisham','Ola','Wael','Nesreen','Eslam','Shimaa','Kareem','Aya',
            'Osama','Rania','Ehab','Doaa','Hazem','Marwa','Tarek','Iman','Magdy','Heba',
            'Alaa','Nada','Reda','Fatma','Gamal','Maha','Sayed','Nagwa','Farid','Sanaa',
            'Medhat','Amal','Nabil','Soha','Ragab','Nawal','Maher','Samia','Farouk','Zeinab'
        ),
        ' ',
        ELT(((n + 37) % 50) + 1,
            'Al-Ahmad','Al-Hassan','Al-Ali','Al-Mohamed','Al-Omar','Al-Ibrahim','Al-Khalid','Al-Yusuf','Al-Mahmoud','Al-Tariq',
            'Al-Saeed','Al-Rashid','Al-Nasser','Al-Hamza','Al-Karim','Al-Sami','Al-Fadi','Al-Nader','Al-Rami','Al-Samir',
            'Al-Walid','Al-Majid','Al-Bassam','Al-Adel','Al-Munir','Al-Jamal','Al-Fouad','Mahmoud','Hassan','Abdullah',
            'Al-Masri','Al-Shami','Al-Iraqi','Al-Sudani','Al-Maghribi','Al-Tunisi','Al-Jazairi','Al-Libi','Al-Yamani','Al-Khaliji',
            'Abdel-Rahman','Abdel-Aziz','Abdel-Hamid','Abdel-Majid','Abdel-Fattah','Abdel-Latif','Abdel-Halim','Abdel-Nasser','Abdel-Wahab','Abdel-Salam'
        ),
        ' - ',
        LPAD(n, 6, '0')
    ) AS full_name,
    
    -- Generate unique phone numbers
    CONCAT(
        '01',
        ELT(((n-1) % 5) + 1, '0', '1', '2', '5', '9'),
        LPAD(
            CONV(
                SUBSTRING(
                    MD5(CONCAT('phone_', n, '_', UNIX_TIMESTAMP())), 
                    1, 8
                ), 
                16, 10
            ) % 100000000, 
            8, '0'
        )
    ) AS phone,
    
    -- Distribute across grades and sections
    CONCAT(
        'Grade ',
        CASE 
            WHEN n <= 10000 THEN '1'
            WHEN n <= 20000 THEN '2'
            WHEN n <= 30000 THEN '3'
            WHEN n <= 40000 THEN '4'
            WHEN n <= 50000 THEN '5'
            WHEN n <= 60000 THEN '6'
            WHEN n <= 70000 THEN '7'
            WHEN n <= 80000 THEN '8'
            WHEN n <= 90000 THEN '9'
            ELSE '10'
        END,
        '-',
        ELT(((n-1) % 8) + 1, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')
    ) AS class
    
FROM numbers
WHERE n <= 100000
ORDER BY n;

COMMIT;

-- Step 5: Clean up and restore settings
DROP TEMPORARY TABLE numbers;

SET autocommit = 1;
SET unique_checks = 1;
SET foreign_key_checks = 1;
SET sql_log_bin = 1;

-- Step 6: Verify results
SELECT 
    COUNT(*) as total_students,
    COUNT(DISTINCT full_name) as unique_names,
    COUNT(DISTINCT phone) as unique_phones,
    COUNT(DISTINCT class) as total_classes,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created
FROM students;

-- Show class distribution
SELECT 
    class,
    COUNT(*) as student_count
FROM students 
GROUP BY class 
ORDER BY class;

SELECT 'Successfully generated 100,000 students with optimized performance!' AS Result;