/*
	Куликов Леонид
	6103
	Вариант 2. БД поликлиники.
*/

/* Л.р. №4. Работа со средствами динамического SQL. */

/*
Создать процедуру, которая принимает в качестве параметров имя таблицы и имена 4-х полей в этой таблице.
Первое поле она интерпретирует как ФИО, разбивает его на составляющие и заполняет три оставшихся поля.
Если значение первого поля не может быть правильно проинтерпретировано как ФИО
(отсутствует отчество, имя и отчество или в строке встречаются недопустимые символы),
она помещает в специальную таблицу это значение и соответствующее значение ключа базы данных (ROWID).
 */

create or replace procedure parse_fio(table_name string, fio_field string, sur_field string, name_field string, pat_field string) as
    fio string(300);
    row_id string(20);
    cur sys_refcursor;
    query string(300);
    sur_name string(100);
    name string(100);
    patronymic string(100);
begin
    open cur for 'select ' || fio_field || ', ' || 'ROWID from ' || table_name;
    loop
        fetch cur into fio, row_id;
        exit when cur%NOTFOUND;

        if shorten_name(fio) = '#############' then
            -- Put value and ROWID to special table
            query := 'insert into ' || 'err_' || table_name || ' (row_id, fio)' || ' values (:1, :2)';
            execute immediate query using row_id, fio;
        else
            -- Parse fio and fill atom values within row
            sur_name := regexp_substr(fio, '^\w+');
            name := regexp_substr(fio, ' \w+ ');
            patronymic := regexp_substr(fio, ' \w+$');
            query := 'update ' || table_name || ' set ' || sur_field || ' = :1, ' || name_field || ' = :2, ' || pat_field || ' = :3 where ROWID = :4';
            execute immediate query using sur_name, name, patronymic, row_id;
        end if;
    end loop;
    close cur;
end;

/* Code below is for testing purpose */
drop table fio_tab;
CREATE TABLE fio_tab (
	id INTEGER NOT NULL PRIMARY KEY,
	fio varchar(300) NOT NULL,
	name varchar(60),
	sur varchar(40),
	pat varchar(60)
);

INSERT INTO fio_tab (id, fio)
VALUES (0, 'Пупкин Василий Пупкинович');
INSERT INTO fio_tab (id, fio)
VALUES (1, 'Папалардо Арина Генадьевна');
INSERT INTO fio_tab (id, fio)
VALUES (2, 'Дронова Зинаида Васильевна');
INSERT INTO fio_tab (id, fio)
VALUES (3, '111');

select * from fio_tab;

drop table err_fio_tab;
CREATE TABLE err_fio_tab (
	row_id varchar(20),
    fio varchar(300)
);

select * from err_fio_tab;

begin
    parse_fio('fio_tab', 'fio', 'sur', 'name', 'pat');
end;