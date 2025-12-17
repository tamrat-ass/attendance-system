-- ============================================
-- INSERT STUDENTS INTO CLASSES
-- SQL queries to add students to specific classes
-- ============================================

-- Insert students into Grade 1
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Abebe Kebede Tadesse', '+251911234567', 'Grade 1', 'Male'),
('Almaz Haile Mariam', '+251922345678', 'Grade 1', 'Female'),
('Dawit Tesfaye Wolde', '+251933456789', 'Grade 1', 'Male'),
('Hanan Mohammed Ali', '+251944567890', 'Grade 1', 'Female'),
('Kidist Girma Bekele', '+251955678901', 'Grade 1', 'Female');

-- Insert students into Grade 2
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Meron Desta Amare', '+251966789012', 'Grade 2', 'Female'),
('Natnael Yohannes Gebre', '+251977890123', 'Grade 2', 'Male'),
('Rahel Mulugeta Teshome', '+251988901234', 'Grade 2', 'Female'),
('Samuel Getachew Negash', '+251999012345', 'Grade 2', 'Male'),
('Tigist Assefa Lemma', '+251900123456', 'Grade 2', 'Female');

-- Insert students into Grade 3
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Yonas Berhe Kahsay', '+251911234568', 'Grade 3', 'Male'),
('Zara Abdella Hussein', '+251922345679', 'Grade 3', 'Female'),
('Biniam Tekle Hagos', '+251933456780', 'Grade 3', 'Male'),
('Danait Mehari Gebru', '+251944567891', 'Grade 3', 'Female'),
('Ephrem Tadele Worku', '+251955678902', 'Grade 3', 'Male');

-- Insert students into Grade 4
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Feven Solomon Desta', '+251966789013', 'Grade 4', 'Female'),
('Getnet Alemu Shiferaw', '+251977890124', 'Grade 4', 'Male'),
('Helen Tsegaye Molla', '+251988901235', 'Grade 4', 'Female'),
('Israel Berhanu Tilahun', '+251999012346', 'Grade 4', 'Male'),
('Jemila Seid Ahmed', '+251900123457', 'Grade 4', 'Female');

-- Insert students into Grade 5
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Kalkidan Worku Desta', '+251911234569', 'Grade 5', 'Female'),
('Leul Habtamu Girma', '+251922345680', 'Grade 5', 'Male'),
('Mahlet Bekele Taye', '+251933456781', 'Grade 5', 'Female'),
('Natan Yemane Tekle', '+251944567892', 'Grade 5', 'Male'),
('Obsinet Tadesse Wolde', '+251955678903', 'Grade 5', 'Female');

-- Insert students into Grade 6
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Paulos Gebre Medhin', '+251966789014', 'Grade 6', 'Male'),
('Qedest Mulugeta Haile', '+251977890125', 'Grade 6', 'Female'),
('Robel Tesfaye Negash', '+251988901236', 'Grade 6', 'Male'),
('Selamawit Assefa Lemma', '+251999012347', 'Grade 6', 'Female'),
('Tewodros Berhe Kahsay', '+251900123458', 'Grade 6', 'Male');

-- Insert students into Grade 7
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Urael Abdella Hussein', '+251911234570', 'Grade 7', 'Female'),
('Veronica Tekle Hagos', '+251922345681', 'Grade 7', 'Female'),
('Wondwossen Mehari Gebru', '+251933456782', 'Grade 7', 'Male'),
('Xenia Tadele Worku', '+251944567893', 'Grade 7', 'Female'),
('Yared Solomon Desta', '+251955678904', 'Grade 7', 'Male');

-- Insert students into Grade 8
INSERT INTO students (full_name, phone, class, gender) VALUES 
('Zelalem Alemu Shiferaw', '+251966789015', 'Grade 8', 'Male'),
('Amanuel Tsegaye Molla', '+251977890126', 'Grade 8', 'Male'),
('Bethlehem Berhanu Tilahun', '+251988901237', 'Grade 8', 'Female'),
('Caleb Seid Ahmed', '+251999012348', 'Grade 8', 'Male'),
('Danielle Worku Desta', '+251900123459', 'Grade 8', 'Female');

-- ============================================
-- VERIFY INSERTIONS
-- ============================================

-- Check total students per class
SELECT 
    class,
    COUNT(*) as student_count,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) as male_count,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) as female_count
FROM students 
GROUP BY class 
ORDER BY class;

-- Check all students
SELECT 
    id,
    full_name,
    phone,
    class,
    gender,
    created_at
FROM students 
ORDER BY class, full_name;

-- ============================================
-- ADDITIONAL UTILITY QUERIES
-- ============================================

-- Insert single student into specific class
-- INSERT INTO students (full_name, phone, class, gender) VALUES 
-- ('Student Name', '+251912345678', 'Grade 1', 'Male');

-- Update student's class
-- UPDATE students SET class = 'Grade 2' WHERE id = 1;

-- Move all students from one class to another
-- UPDATE students SET class = 'Grade 2' WHERE class = 'Grade 1';

-- Delete students from specific class
-- DELETE FROM students WHERE class = 'Grade 1';

-- Get students in specific class
-- SELECT * FROM students WHERE class = 'Grade 1' ORDER BY full_name;