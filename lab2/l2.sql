-- не принята

-- Куликов Леонид
-- 6103
-- Вариант 2


-- Л.р. №2. Выборка данных. 
-- Один из запросов надо написать двумя способами и объяснить, 
-- какой из вариантов будет работать быстрее и почему.


-- Проверить, что между любыми двумя визитами к одному и тому же врачу проходит 
-- не меньше 15 минут. 

-- Первый вариант (более быстрый, так как не делает селекции на каждой строке,
-- хоть и оперирует с декартовым произведением)
SELECT i.*, j.id intersected_v_id
FROM visit_to_doc i, visit_to_doc j
WHERE 
    i.id < j.id 
    AND i.doctor = j.doctor 
    AND ABS(EXTRACT(EPOCH FROM (i.visit_time - j.visit_time))) < 15 * 60;
-- лучше выдавать не count, а сами визиты (+)

-- Второй вариант
SELECT v.*, 
        (
            SELECT id FROM visit_to_doc 
                WHERE id > v.id AND ABS(EXTRACT(EPOCH FROM (visit_time - v.visit_time))) < 15 * 60
        ) intersected_v_id
    FROM visit_to_doc v
EXCEPT
SELECT *, NULL
    FROM visit_to_doc;


-- Посчитать количество диагнозов простудных заболеваний (ОРЗ, ОРВИ, грипп), 
-- поставленных за последнюю неделю. 
SELECT COUNT(*)
FROM visit_to_doc
WHERE 
    diagnosis IN ('ОРЗ', 'ОРВИ', 'грипп')
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) < 7 * 24 * 60 * 60
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) > 0;
--+

-- Создать упорядоченные списки:

-- визитов к врачам с указанием даты-времени, ФИО врача и ФИО пациента;

-- Первый вариант
SELECT visit_time, d.name, p.name
FROM visit_to_doc v, doc d, pat p
WHERE v.doctor = d.id AND v.patient = p.id
ORDER BY visit_time;
--+

-- Второй вариант
SELECT visit_time, d.name, p.name
FROM visit_to_doc v
JOIN doc d ON v.doctor = d.id
JOIN pat p ON v.patient = p.id
ORDER BY visit_time;
-- это не другой вариант, это другая форма записи соединения (не считается) -> 
-- добавил второй вариант к 1й задаче (+)

-- количества приемов каждым врачом за сегодняшний день;
SELECT d.name, COUNT(*) AS number_of_appoints
FROM appoint a
JOIN visit_to_doc v ON a.visit = v.id
JOIN doc d ON v.doctor = d.id
WHERE DATE(v.visit_time) = CURRENT_DATE
GROUP BY d.name
ORDER BY number_of_appoints;
-- за сегодняшний день!!!! (+)

-- пациентов для всех терапевтов с указанием диагнозов.
SELECT DISTINCT d.name, p.name, v.diagnosis
FROM pat p, doc d, visit_to_doc v
WHERE
    d.post = 'Терапевт'
    AND v.doctor = d.id
    AND v.patient = p.id
ORDER BY p.name;
--+
