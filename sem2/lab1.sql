/*
	Куликов Леонид
	6103
	Вариант 2. БД поликлиники.
*/

/* Л.Р. №1. Создание функций. */

-- 1. Функция, принимающая на вход номер полиса и возвращающая строку с этим номером,
-- разбитую на две части пробелом после 6-го символа. Если исходный номер содержит меньше 16-ти цифр,
-- возвращать '###########'.
create or replace function cut_polis(num string) return string is
begin
    if (LENGTH(num) < 16) then
        return '###########';
    else
        return substr(num, 1, 6) || ' ' || substr(num, 7);
    end if;
end;

-- 2. Функция, преобразующая значение ФИО (один входной параметр) в фамилию с инициалами
-- (например, "Иванов Иван Сергеевич" в "Иванов И.С."). При невозможности преобразования функция
-- возвращает строку '#############'.
create or replace function shorten_name(name string) return string is
    tmp string(100);
begin
    -- Remove spaces in the beginning
    tmp := regexp_replace(name, '^[[:space:]]+', '');
    -- Remove spaces in the end
    tmp := regexp_replace(tmp, '[[:space:]]+$', '');
    -- Keep only one space in the middle
    tmp := regexp_replace(tmp, '[[:space:]]+', ' ');
    -- Check that we have 3 parts in name => i.e. 2 spaces
    if (regexp_count(tmp, '[[:space:]]') <> 2) then
        return '#############';
    else
        return regexp_substr(tmp, '^\w+')  -- Surname
                   || substr(regexp_substr(tmp, ' \w'), 1, 2) || '.'  -- First letter of name + '.'
                   || substr(regexp_substr(tmp, ' \w', 1, 2), 2, 3) || '.';  -- First letter of patronymic + '.'
    end if;
end;

-- 3. Функция, определяющая, является ли человек пенсионером по полу и дате рождения.
-- Возвращает строку "пенсионер" или пустую строку.
create or replace function is_pensioner(sex char, birthdate string) return string is
    pensioner_age_edge number(2);
begin
    if (sex = 'm') then
        pensioner_age_edge := 60;
    else
        pensioner_age_edge := 55;
    end if;

    if (((sysdate - to_date(birthdate, 'DD/MM/YYYY')) / 365) >= pensioner_age_edge) then
        return 'пенсионер';
    else
        return '';
    end if;
end;

declare
   procedure assert (condition boolean, error_message string default 'F') is
   begin
       if (condition) then
           return;
       end if;

       raise_application_error(-20001, error_message);
   end assert;
begin
    -- Test 1
    assert(cut_polis('1943') = '###########', 'F1');
    assert(cut_polis('2456100826000229') = '245610 0826000229', 'F2');

    -- Test 2
    assert(shorten_name('Куликов Леонид Андреевич') = 'Куликов Л.А.', 'F3');
    assert(shorten_name('  Куликов   Леонид Андреевич  ') = 'Куликов Л.А.', 'F4');
    assert(shorten_name('  Куликов   Леонид А') = 'Куликов Л.А.', 'F5');
    assert(shorten_name('  Куликов   Л А') = 'Куликов Л.А.', 'F6');
    assert(shorten_name('  К  Л   А  ') = 'К Л.А.', 'F7');
    assert(shorten_name('Куликов') = '#############', 'F8');
    assert(shorten_name('Куликов Леонид') = '#############', 'F9');
    assert(shorten_name('Куликов Леонид  ') = '#############', 'F10');
    assert(shorten_name('  Куликов Леонид') = '#############', 'F11');

    -- Test 3
    assert(is_pensioner('m', '23/03/1998') is null, 'F12');
    assert(is_pensioner('m', '23/03/1961') is null, 'F13');
    assert(is_pensioner('f', '23/03/1966') is null, 'F14');
    assert(is_pensioner('m', '23/03/1960') = 'пенсионер', 'F15');
    assert(is_pensioner('f', '23/03/1965') = 'пенсионер', 'F16');
end;