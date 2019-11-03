-- Куликов Леонид
-- 6103
-- Вариант 2

-- Л.р. №3. Работа с представлениями. 


-- Для созданных представлений необходимо проверить с помощью запросов UPDATE и INSERT, 
-- являются ли они обновляемыми, и объяснить полученный результат.



-- Представление "Специализация клиники": 
-- диагноз – количество пациентов-мужчин – количество пациентов-женщин.

CREATE OR REPLACE VIEW clinic_spec(diagnosis, count_m_pat, count_f_pat)
    AS SELECT v.diagnosis, 
              COUNT(DISTINCT CASE p.sex when 'm' then 1 else null end), 
              COUNT(DISTINCT CASE p.sex when 'f' then 1 else null end)
    FROM visit_to_doc v, pat p
    WHERE 
        v.patient = p.id
    GROUP BY v.diagnosis;

INSERT INTO clinic_spec(diagnosis, count_m_pat, count_f_pat)
    VALUES ('TEST DIAGNOSIS', 5, 4),
           ('TEST2 DIAGNOSIS', 1, 3);
           
-- ERROR:  cannot insert into view "clinic_spec"
-- DETAIL:  Views containing GROUP BY are not automatically updatable.

UPDATE clinic_spec
    SET diagnosis = 'TEST DIAGNOSIS'
    WHERE count_m_pat = 3;

-- ERROR:  cannot update view "clinic_spec"
-- DETAIL:  Views containing GROUP BY are not automatically updatable.


-- Представление "Пациенты врачей-хирургов".

CREATE OR REPLACE VIEW sur_pats(patient, surgeon)
    AS SELECT DISTINCT p.name, d.name
    FROM visit_to_doc v, doc d, pat p
    WHERE 
        d.post = 'Хирург'
        AND v.doctor = d.id
        AND v.patient = p.id;

INSERT INTO sur_pats(patient, surgeon)
    VALUES ('Шарик', 'Филипп Филиппович Преображенский');

-- ERROR:  cannot insert into view "sur_pats"
-- DETAIL:  Views containing DISTINCT are not automatically updatable.

UPDATE sur_pats
    SET surgeon = 'Иван Арнольдович Борменталь'
    WHERE patient IN ('Шарик', 'Треугольник', 'Квадратик');

-- ERROR:  cannot update view "sur_pats"
-- DETAIL:  Views containing DISTINCT are not automatically updatable.

-- Представление "Загруженность врачей разных специализаций": 
-- специализация – количество пациентов.

CREATE OR REPLACE VIEW load_spec(specialization, number_of_patients)
    AS SELECT d.spec, COUNT(DISTINCT v.patient)
    FROM doc d, visit_to_doc v
    WHERE v.doctor = d.id
    GROUP BY d.spec; 

INSERT INTO load_spec(specialization, number_of_patients)
    VALUES ('Психические заболевания', 15);

-- ERROR:  cannot insert into view "load_spec"
-- DETAIL:  Views containing GROUP BY are not automatically updatable.

UPDATE load_spec
    SET number_of_patients = 5
    WHERE specialization = 'Психические заболевания';

-- ERROR:  cannot update view "load_spec"
-- DETAIL:  Views containing GROUP BY are not automatically updatable.
