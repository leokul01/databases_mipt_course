-- Куликов Леонид
-- 6103
-- Вариант 2


-- Л.р. №2. Выборка данных. 
-- Один из запросов надо написать двумя способами и объяснить, 
-- какой из вариантов будет работать быстрее и почему.


-- Проверить, что между любыми двумя визитами к одному и тому же врачу проходит 
-- не меньше 15 минут. 

-- Если результат больше 0, значит между какими-то двумя визитами к одному и тому же врачу проходит 
-- меньше 15 минут.
-- Знаю, выглядит не очень красиво :(
SELECT COUNT(*)
FROM visit_to_doc i, visit_to_doc j
WHERE 
    i.id < j.id 
    AND i.doctor = j.doctor 
    AND ABS(EXTRACT(EPOCH FROM (i.visit_time - j.visit_time))) < 15 * 60;


-- Посчитать количество диагнозов простудных заболеваний (ОРЗ, ОРВИ, грипп), 
-- поставленных за последнюю неделю. 
SELECT COUNT(*)
FROM visit_to_doc
WHERE 
    diagnosis IN ('ОРЗ', 'ОРВИ', 'грипп')
    AND ABS(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time))) < 7 * 24 * 60 * 60;


-- Создать упорядоченные списки:

-- визитов к врачам с указанием даты-времени, ФИО врача и ФИО пациента;

-- Первый вариант
SELECT visit_time, d.name, p.name
FROM visit_to_doc v, doc d, pat p
WHERE v.doctor = d.id AND v.patient = p.id
ORDER BY visit_time;

-- Второй вариант (скорость та же)
SELECT visit_time, d.name, p.name
FROM visit_to_doc v
JOIN doc d ON v.doctor = d.id
JOIN pat p ON v.patient = p.id
ORDER BY visit_time;

-- количества приемов каждым врачом за сегодняшний день;
SELECT d.name, COUNT(*) AS number_of_appoints
FROM appoint a
JOIN visit_to_doc v ON a.visit = v.id
JOIN doc d ON v.doctor = d.id
GROUP BY d.name
ORDER BY number_of_appoints;


-- пациентов для всех терапевтов с указанием диагнозов.
SELECT DISTINCT d.name, p.name, v.diagnosis
FROM pat p, doc d, visit_to_doc v
WHERE
    d.post = 'Терапевт'
    AND v.doctor = d.id
    AND v.patient = p.id
ORDER BY p.name;
