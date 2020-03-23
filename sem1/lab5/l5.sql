-- Куликов Леонид
-- 6103
-- Вариант 2


-- Л.р. №5. Оптимизация запросов.

-- 1. Заполнение таблицы (+)

-- 2. Выполнить запросы из л.р. 2 и 3 и проанализировать планы их выполнения.

SELECT i.*, j.id intersected_v_id
FROM visit_to_doc i, visit_to_doc j
WHERE 
    i.id < j.id 
    AND i.doctor = j.doctor 
    AND ABS(EXTRACT(EPOCH FROM (i.visit_time - j.visit_time))) < 15 * 60;

/*
 Hash Join  (cost=16.75..51.88 rows=50 width=242) (actual time=1.734..1.748 rows=4 loops=1)
   Output: i.id, i.doctor, i.patient, i.visit_time, i.diagnosis, j.id
   Hash Cond: (i.doctor = j.doctor)
   Join Filter: ((i.id < j.id) AND (abs(date_part('epoch'::text, (i.visit_time - j.visit_time))) < '900'::double precision))
   Rows Removed by Join Filter: 24
   Buffers: shared hit=2
   ->  Seq Scan on public.visit_to_doc i  (cost=0.00..13.00 rows=300 width=238) (actual time=0.039..0.041 rows=8 loops=1)
         Output: i.id, i.doctor, i.patient, i.visit_time, i.diagnosis
         Buffers: shared hit=1
   ->  Hash  (cost=13.00..13.00 rows=300 width=16) (actual time=0.054..0.054 rows=8 loops=1)
         Output: j.id, j.doctor, j.visit_time
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         Buffers: shared hit=1
         ->  Seq Scan on public.visit_to_doc j  (cost=0.00..13.00 rows=300 width=16) (actual time=0.026..0.030 rows=8 loops=1)
               Output: j.id, j.doctor, j.visit_time
               Buffers: shared hit=1
 Planning Time: 0.400 ms
 Execution Time: 1.883 ms
*/

SELECT COUNT(*)
FROM visit_to_doc
WHERE 
    diagnosis IN ('ОРЗ', 'ОРВИ', 'грипп')
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) < 7 * 24 * 60 * 60
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) > 0;

/*
 Aggregate  (cost=21.63..21.64 rows=1 width=8) (actual time=0.665..0.665 rows=1 loops=1)
   Output: count(*)
   Buffers: shared hit=1
   ->  Seq Scan on public.visit_to_doc  (cost=0.00..21.62 rows=1 width=0) (actual time=0.611..0.611 rows=0 loops=1)
         Output: id, doctor, patient, visit_time, diagnosis
         Filter: (((visit_to_doc.diagnosis)::text = ANY ('{ОРЗ,ОРВИ,грипп}'::text[])) AND (date_part('epoch'::text, (CURRENT_TIMESTAMP - (visit_to_doc.visit_time)::timestamp with time zone)) < '604800'::double precision) AND (date_part('epoch'::text, (CURRENT_TIMESTAMP - (visit_to_doc.visit_time)::timestamp with time zone)) > '0'::double precision))
         Rows Removed by Filter: 8
         Buffers: shared hit=1
 Planning Time: 2.824 ms
 Execution Time: 8.953 ms
*/

SELECT visit_time, d.name, p.name
FROM visit_to_doc v, doc d, pat p
WHERE v.doctor = d.id AND v.patient = p.id
ORDER BY visit_time;

/*
Sort  (cost=56.40..57.15 rows=300 width=204) (actual time=1.241..1.242 rows=8 loops=1)
   Output: v.visit_time, d.name, p.name
   Sort Key: v.visit_time
   Sort Method: quicksort  Memory: 26kB
   Buffers: shared hit=6
   ->  Hash Join  (cost=29.45..44.06 rows=300 width=204) (actual time=0.119..0.128 rows=8 loops=1)
         Output: v.visit_time, d.name, p.name
         Inner Unique: true
         Hash Cond: (v.patient = p.id)
         Buffers: shared hit=3
         ->  Hash Join  (cost=14.50..28.31 rows=300 width=110) (actual time=0.059..0.065 rows=8 loops=1)
               Output: v.visit_time, v.patient, d.name
               Inner Unique: true
               Hash Cond: (v.doctor = d.id)
               Buffers: shared hit=2
               ->  Seq Scan on public.visit_to_doc v  (cost=0.00..13.00 rows=300 width=16) (actual time=0.010..0.011 rows=8 loops=1)
                     Output: v.id, v.doctor, v.patient, v.visit_time, v.diagnosis
                     Buffers: shared hit=1
               ->  Hash  (cost=12.00..12.00 rows=200 width=102) (actual time=0.026..0.026 rows=8 loops=1)
                     Output: d.name, d.id
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
                     Buffers: shared hit=1
                     ->  Seq Scan on public.doc d  (cost=0.00..12.00 rows=200 width=102) (actual time=0.011..0.013 rows=8 loops=1)
                           Output: d.name, d.id
                           Buffers: shared hit=1
         ->  Hash  (cost=12.20..12.20 rows=220 width=102) (actual time=0.040..0.040 rows=6 loops=1)
               Output: p.name, p.id
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               Buffers: shared hit=1
               ->  Seq Scan on public.pat p  (cost=0.00..12.20 rows=220 width=102) (actual time=0.021..0.023 rows=6 loops=1)
                     Output: p.name, p.id
                     Buffers: shared hit=1
 Planning Time: 4.412 ms
 Execution Time: 1.333 ms
*/

SELECT d.name, COUNT(*) AS number_of_appoints
FROM appoint a
JOIN visit_to_doc v ON a.visit = v.id
JOIN doc d ON v.doctor = d.id
WHERE DATE(v.visit_time) = CURRENT_DATE
GROUP BY d.name
ORDER BY number_of_appoints;

/*
Sort  (cost=42.55..42.55 rows=2 width=106) (actual time=0.248..0.248 rows=0 loops=1)
   Output: d.name, (count(*))
   Sort Key: (count(*))
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=9 dirtied=1
   ->  GroupAggregate  (cost=42.50..42.54 rows=2 width=106) (actual time=0.200..0.200 rows=0 loops=1)
         Output: d.name, count(*)
         Group Key: d.name
         Buffers: shared hit=6 dirtied=1
         ->  Sort  (cost=42.50..42.51 rows=2 width=98) (actual time=0.197..0.197 rows=0 loops=1)
               Output: d.name
               Sort Key: d.name
               Sort Method: quicksort  Memory: 25kB
               Buffers: shared hit=6 dirtied=1
               ->  Hash Join  (cost=28.07..42.49 rows=2 width=98) (actual time=0.140..0.140 rows=0 loops=1)
                     Output: d.name
                     Hash Cond: (a.visit = v.id)
                     Buffers: shared hit=3 dirtied=1
                     ->  Seq Scan on public.appoint a  (cost=0.00..13.20 rows=320 width=4) (actual time=0.037..0.037 rows=1 loops=1)
                           Output: a.visit, a.dest
                           Buffers: shared hit=1 dirtied=1
                     ->  Hash  (cost=28.05..28.05 rows=2 width=102) (actual time=0.074..0.074 rows=0 loops=1)
                           Output: v.id, d.name
                           Buckets: 1024  Batches: 1  Memory Usage: 8kB
                           Buffers: shared hit=2
                           ->  Hash Join  (cost=15.28..28.05 rows=2 width=102) (actual time=0.073..0.074 rows=0 loops=1)
                                 Output: v.id, d.name
                                 Hash Cond: (d.id = v.doctor)
                                 Buffers: shared hit=2
                                 ->  Seq Scan on public.doc d  (cost=0.00..12.00 rows=200 width=102) (actual time=0.008..0.008 rows=1 loops=1)
                                       Output: d.id, d.name, d.post, d.spec, d.cab_num
                                       Buffers: shared hit=1
                                 ->  Hash  (cost=15.25..15.25 rows=2 width=8) (actual time=0.042..0.043 rows=0 loops=1)
                                       Output: v.id, v.doctor
                                       Buckets: 1024  Batches: 1  Memory Usage: 8kB
                                       Buffers: shared hit=1
                                       ->  Seq Scan on public.visit_to_doc v  (cost=0.00..15.25 rows=2 width=8) (actual time=0.041..0.041 rows=0 loops=1)
                                             Output: v.id, v.doctor
                                             Filter: (date(v.visit_time) = CURRENT_DATE)
                                             Rows Removed by Filter: 8
                                             Buffers: shared hit=1
 Planning Time: 6.495 ms
 Execution Time: 0.429 ms
*/

SELECT DISTINCT d.name, p.name, v.diagnosis
FROM pat p, doc d, visit_to_doc v
WHERE
    d.post = 'Терапевт'
    AND v.doctor = d.id
    AND v.patient = p.id
ORDER BY p.name;

/*
Unique  (cost=26.98..27.00 rows=2 width=414) (actual time=0.517..0.518 rows=1 loops=1)
   Output: d.name, p.name, v.diagnosis
   Buffers: shared hit=4
   ->  Sort  (cost=26.98..26.98 rows=2 width=414) (actual time=0.516..0.517 rows=1 loops=1)
         Output: d.name, p.name, v.diagnosis
         Sort Key: p.name, d.name, v.diagnosis
         Sort Method: quicksort  Memory: 25kB
         Buffers: shared hit=4
         ->  Nested Loop  (cost=12.66..26.97 rows=2 width=414) (actual time=0.484..0.487 rows=1 loops=1)
               Output: d.name, p.name, v.diagnosis
               Inner Unique: true
               Buffers: shared hit=4
               ->  Hash Join  (cost=12.51..26.32 rows=2 width=320) (actual time=0.107..0.110 rows=1 loops=1)
                     Output: d.name, v.diagnosis, v.patient
                     Inner Unique: true
                     Hash Cond: (v.doctor = d.id)
                     Buffers: shared hit=2
                     ->  Seq Scan on public.visit_to_doc v  (cost=0.00..13.00 rows=300 width=226) (actual time=0.013..0.015 rows=8 loops=1)
                           Output: v.id, v.doctor, v.patient, v.visit_time, v.diagnosis
                           Buffers: shared hit=1
                     ->  Hash  (cost=12.50..12.50 rows=1 width=102) (actual time=0.042..0.042 rows=1 loops=1)
                           Output: d.name, d.id
                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                           Buffers: shared hit=1
                           ->  Seq Scan on public.doc d  (cost=0.00..12.50 rows=1 width=102) (actual time=0.028..0.031 rows=1 loops=1)
                                 Output: d.name, d.id
                                 Filter: ((d.post)::text = 'Терапевт'::text)
                                 Rows Removed by Filter: 7
                                 Buffers: shared hit=1
               ->  Index Scan using pat_pkey on public.pat p  (cost=0.14..0.32 rows=1 width=102) (actual time=0.090..0.090 rows=1 loops=1)
                     Output: p.id, p.name, p.sex, p.birth_date, p.polis_num, p.address, p.phone
                     Index Cond: (p.id = v.patient)
                     Buffers: shared hit=2
 Planning Time: 1.963 ms
 Execution Time: 1.601 ms
*/


-- 3. Create indexes
CREATE INDEX visit_to_doc_visit_time_index ON  visit_to_doc(visit_time);
CREATE INDEX visit_to_doc_doctor_index ON  visit_to_doc(doctor);
CREATE INDEX visit_to_doc_diagnosis_index ON  visit_to_doc(diagnosis);
CREATE INDEX visit_to_doc_patient_index ON  visit_to_doc(patient);
CREATE INDEX doc_name_index ON doc(name);
CREATE INDEX doc_post_index ON doc(post);
CREATE INDEX pat_name_index ON pat(name);
CREATE INDEX appoint_visit_index ON appoint(visit);


SELECT i.*, j.id intersected_v_id
FROM visit_to_doc i, visit_to_doc j
WHERE 
    i.id < j.id 
    AND i.doctor = j.doctor 
    AND ABS(EXTRACT(EPOCH FROM (i.visit_time - j.visit_time))) < 15 * 60;

/*
 Hash Join  (cost=1.18..2.47 rows=1 width=242) (actual time=2.157..2.170 rows=4 loops=1)
   Output: i.id, i.doctor, i.patient, i.visit_time, i.diagnosis, j.id
   Hash Cond: (i.doctor = j.doctor)
   Join Filter: ((i.id < j.id) AND (abs(date_part('epoch'::text, (i.visit_time - j.visit_time))) < '900'::double precision))
   Rows Removed by Join Filter: 24
   Buffers: shared hit=2
   ->  Seq Scan on public.visit_to_doc i  (cost=0.00..1.08 rows=8 width=238) (actual time=0.477..0.481 rows=8 loops=1)
         Output: i.id, i.doctor, i.patient, i.visit_time, i.diagnosis
         Buffers: shared hit=1
   ->  Hash  (cost=1.08..1.08 rows=8 width=16) (actual time=0.027..0.027 rows=8 loops=1)
         Output: j.id, j.doctor, j.visit_time
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         Buffers: shared hit=1
         ->  Seq Scan on public.visit_to_doc j  (cost=0.00..1.08 rows=8 width=16) (actual time=0.016..0.019 rows=8 loops=1)
               Output: j.id, j.doctor, j.visit_time
               Buffers: shared hit=1
 Planning Time: 4.498 ms
 Execution Time: 2.629 ms
*/

SELECT COUNT(*)
FROM visit_to_doc
WHERE 
    diagnosis IN ('ОРЗ', 'ОРВИ', 'грипп')
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) < 7 * 24 * 60 * 60
    AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - visit_time)) > 0;

/*
 Aggregate  (cost=1.31..1.32 rows=1 width=8) (actual time=1.116..1.117 rows=1 loops=1)
   Output: count(*)
   Buffers: shared hit=1
   ->  Seq Scan on public.visit_to_doc  (cost=0.00..1.31 rows=1 width=0) (actual time=0.554..0.554 rows=0 loops=1)
         Output: id, doctor, patient, visit_time, diagnosis
         Filter: (((visit_to_doc.diagnosis)::text = ANY ('{ОРЗ,ОРВИ,грипп}'::text[])) AND (date_part('epoch'::text, (CURRENT_TIMESTAMP - (visit_to_doc.visit_time)::timestamp with time zone)) < '604800'::double precision) AND (date_part('epoch'::text, (CURRENT_TIMESTAMP - (visit_to_doc.visit_time)::timestamp with time zone)) > '0'::double precision))
         Rows Removed by Filter: 8
         Buffers: shared hit=1
 Planning Time: 0.687 ms
 Execution Time: 6.527 ms
*/

SELECT visit_time, d.name, p.name
FROM visit_to_doc v, doc d, pat p
WHERE v.doctor = d.id AND v.patient = p.id
ORDER BY visit_time;

/*
Sort  (cost=3.58..3.60 rows=8 width=204) (actual time=1.104..1.117 rows=8 loops=1)
   Output: v.visit_time, d.name, p.name
   Sort Key: v.visit_time
   Sort Method: quicksort  Memory: 26kB
   Buffers: shared hit=3
   ->  Hash Join  (cost=2.32..3.46 rows=8 width=204) (actual time=1.040..1.059 rows=8 loops=1)
         Output: v.visit_time, d.name, p.name
         Inner Unique: true
         Hash Cond: (v.patient = p.id)
         Buffers: shared hit=3
         ->  Hash Join  (cost=1.18..2.29 rows=8 width=110) (actual time=0.966..0.987 rows=8 loops=1)
               Output: v.visit_time, v.patient, d.name
               Inner Unique: true
               Hash Cond: (v.doctor = d.id)
               Buffers: shared hit=2
               ->  Seq Scan on public.visit_to_doc v  (cost=0.00..1.08 rows=8 width=16) (actual time=0.009..0.012 rows=8 loops=1)
                     Output: v.id, v.doctor, v.patient, v.visit_time, v.diagnosis
                     Buffers: shared hit=1
               ->  Hash  (cost=1.08..1.08 rows=8 width=102) (actual time=0.098..0.098 rows=8 loops=1)
                     Output: d.name, d.id
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
                     Buffers: shared hit=1
                     ->  Seq Scan on public.doc d  (cost=0.00..1.08 rows=8 width=102) (actual time=0.012..0.028 rows=8 loops=1)
                           Output: d.name, d.id
                           Buffers: shared hit=1
         ->  Hash  (cost=1.06..1.06 rows=6 width=102) (actual time=0.021..0.021 rows=6 loops=1)
               Output: p.name, p.id
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               Buffers: shared hit=1
               ->  Seq Scan on public.pat p  (cost=0.00..1.06 rows=6 width=102) (actual time=0.011..0.014 rows=6 loops=1)
                     Output: p.name, p.id
                     Buffers: shared hit=1
 Planning Time: 4.556 ms
 Execution Time: 1.297 ms
*/

SELECT d.name, COUNT(*) AS number_of_appoints
FROM appoint a
JOIN visit_to_doc v ON a.visit = v.id
JOIN doc d ON v.doctor = d.id
WHERE DATE(v.visit_time) = CURRENT_DATE
GROUP BY d.name
ORDER BY number_of_appoints;

/*
Sort  (cost=3.41..3.42 rows=1 width=106) (actual time=1.085..1.085 rows=0 loops=1)
   Output: d.name, (count(*))
   Sort Key: (count(*))
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=3
   ->  GroupAggregate  (cost=3.38..3.40 rows=1 width=106) (actual time=1.076..1.076 rows=0 loops=1)
         Output: d.name, count(*)
         Group Key: d.name
         Buffers: shared hit=3
         ->  Sort  (cost=3.38..3.39 rows=1 width=98) (actual time=1.074..1.074 rows=0 loops=1)
               Output: d.name
               Sort Key: d.name
               Sort Method: quicksort  Memory: 25kB
               Buffers: shared hit=3
               ->  Hash Join  (cost=2.25..3.37 rows=1 width=98) (actual time=1.066..1.067 rows=0 loops=1)
                     Output: d.name
                     Hash Cond: (d.id = v.doctor)
                     Buffers: shared hit=3
                     ->  Seq Scan on public.doc d  (cost=0.00..1.08 rows=8 width=102) (actual time=0.023..0.023 rows=1 loops=1)
                           Output: d.id, d.name, d.post, d.spec, d.cab_num
                           Buffers: shared hit=1
                     ->  Hash  (cost=2.24..2.24 rows=1 width=4) (actual time=1.007..1.007 rows=0 loops=1)
                           Output: v.doctor
                           Buckets: 1024  Batches: 1  Memory Usage: 8kB
                           Buffers: shared hit=2
                           ->  Hash Join  (cost=1.15..2.24 rows=1 width=4) (actual time=1.006..1.007 rows=0 loops=1)
                                 Output: v.doctor
                                 Inner Unique: true
                                 Hash Cond: (a.visit = v.id)
                                 Buffers: shared hit=2
                                 ->  Seq Scan on public.appoint a  (cost=0.00..1.06 rows=6 width=4) (actual time=0.006..0.006 rows=1 loops=1)
                                       Output: a.visit, a.dest
                                       Buffers: shared hit=1
                                 ->  Hash  (cost=1.14..1.14 rows=1 width=8) (actual time=0.081..0.081 rows=0 loops=1)
                                       Output: v.id, v.doctor
                                       Buckets: 1024  Batches: 1  Memory Usage: 8kB
                                       Buffers: shared hit=1
                                       ->  Seq Scan on public.visit_to_doc v  (cost=0.00..1.14 rows=1 width=8) (actual time=0.078..0.078 rows=0 loops=1)
                                             Output: v.id, v.doctor
                                             Filter: (date(v.visit_time) = CURRENT_DATE)
                                             Rows Removed by Filter: 8
                                             Buffers: shared hit=1
 Planning Time: 13.666 ms
 Execution Time: 1.213 ms
*/

SELECT DISTINCT d.name, p.name, v.diagnosis
FROM pat p, doc d, visit_to_doc v
WHERE
    d.post = 'Терапевт'
    AND v.doctor = d.id
    AND v.patient = p.id
ORDER BY p.name;

/*
Unique  (cost=3.37..3.38 rows=1 width=414) (actual time=0.068..0.069 rows=1 loops=1)
   Output: d.name, p.name, v.diagnosis
   Buffers: shared hit=3
   ->  Sort  (cost=3.37..3.37 rows=1 width=414) (actual time=0.064..0.064 rows=1 loops=1)
         Output: d.name, p.name, v.diagnosis
         Sort Key: p.name, d.name, v.diagnosis
         Sort Method: quicksort  Memory: 25kB
         Buffers: shared hit=3
         ->  Nested Loop  (cost=1.11..3.36 rows=1 width=414) (actual time=0.047..0.049 rows=1 loops=1)
               Output: d.name, p.name, v.diagnosis
               Inner Unique: true
               Join Filter: (v.patient = p.id)
               Rows Removed by Join Filter: 3
               Buffers: shared hit=3
               ->  Hash Join  (cost=1.11..2.22 rows=1 width=320) (actual time=0.040..0.042 rows=1 loops=1)
                     Output: d.name, v.diagnosis, v.patient
                     Inner Unique: true
                     Hash Cond: (v.doctor = d.id)
                     Buffers: shared hit=2
                     ->  Seq Scan on public.visit_to_doc v  (cost=0.00..1.08 rows=8 width=226) (actual time=0.011..0.012 rows=8 loops=1)
                           Output: v.id, v.doctor, v.patient, v.visit_time, v.diagnosis
                           Buffers: shared hit=1
                     ->  Hash  (cost=1.10..1.10 rows=1 width=102) (actual time=0.012..0.013 rows=1 loops=1)
                           Output: d.name, d.id
                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                           Buffers: shared hit=1
                           ->  Seq Scan on public.doc d  (cost=0.00..1.10 rows=1 width=102) (actual time=0.007..0.009 rows=1 loops=1)
                                 Output: d.name, d.id
                                 Filter: ((d.post)::text = 'Терапевт'::text)
                                 Rows Removed by Filter: 7
                                 Buffers: shared hit=1
               ->  Seq Scan on public.pat p  (cost=0.00..1.06 rows=6 width=102) (actual time=0.004..0.004 rows=4 loops=1)
                     Output: p.id, p.name, p.sex, p.birth_date, p.polis_num, p.address, p.phone
                     Buffers: shared hit=1
 Planning Time: 2.484 ms
 Execution Time: 0.122 ms
*/

-- 4. Придумать запрос с подсказкой оптимизатору, которая бы давала лучшее время выполнения по сравнению с планом, 
-- построенным оптимизатором для этого запроса без подсказки. Запрос может обращаться к любым отношениям 
-- (в том числе, отношениям из лабораторных работ и курсового проекта).
