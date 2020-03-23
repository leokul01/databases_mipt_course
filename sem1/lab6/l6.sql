-- Куликов Леонид
-- 6103
-- Вариант 2


-- Л.р. №6. Изучение механизма транзакций

delete from doc where name = 'Суханов Карл Федотович';
-- DELETE 1

commit;
-- WARNING:  there is no transaction in progress

-- => In psql autocommit is enabled by default for all types of commands (DDL, DML)

-- Recover data
INSERT INTO doc (name, post, spec, cab_num)
VALUES ('Суханов Карл Федотович', 'Эндокринолог', 'Общая', '33');

-- Overriding psql's autocommit default is to explicitly begin a transaction 
-- with the BEGIN keyword and then psql won't commit until an explicit commit is provided

BEGIN;
delete from doc where name = 'Суханов Карл Федотович';
ROLLBACK;

select count(*) from doc where name = 'Суханов Карл Федотович';
-- 1

-- Открываем 2 окна psql

-- ввод 1-го окна
begin;

INSERT INTO doc (name, post, spec, cab_num)
VALUES ('Тест', 'Хирург', 'Конечности', '14');

-- ввод 2-го окна
begin;
select * from doc where name = 'Тест';
-- 0 rows => черновое чтение -

-- ввод 1-го окна
commit;

-- ввод 2-го окна
select * from doc where name = 'Тест';
-- 1 row => фантом +

-- ввод 1-го окна
begin;
update doc set cab_num = 15 where name = 'Тест';
commit;

-- ввод 2-го окна
select * from doc where name = 'Тест';
-- 1 row with cab_num = 15 => неповторяемое чтение +

-- Итог: Уровень изоляции = Read Commited

-- Демонстрация savepoint
begin;
savepoint s;
delete from doc where name = 'Тест';
select * from doc where name = 'Тест';
-- 0 rows
rollback to savepoint s;
select * from doc where name = 'Тест';
-- 1 row
