/*
	Куликов Леонид
	6103
	Вариант 2. БД поликлиники.
*/

/* Л.Р. №3. Создание триггеров. */

-- 1. Реализация ограничения внешнего ключа.

create or replace trigger visit_to_doc_fk_constraint_trigger
    before INSERT or UPDATE
    on VISIT_TO_DOC
    for each row
declare
    count_for_key number;
    fk_empty_exception exception;
begin
    select count(*)
        into count_for_key
        from DOC d
        where d.ID = :NEW.DOCTOR;

    if count_for_key = 0 then
        raise fk_empty_exception;
    end if;
exception
    when fk_empty_exception then
        raise_application_error(-20002, 'Доктора с указазнным идентификатором DOCTOR не существует.');
end;

create or replace trigger doc_fk_constraint_trigger
    before delete
    on DOC
    for each row
declare
    count_for_key number;
    fk_using_exception exception;
begin
    select count(*)
    into count_for_key
    from VISIT_TO_DOC v
    where v.DOCTOR = :OLD.ID;

    if count_for_key <> 0 then
        raise fk_using_exception;
    end if;
exception
    when fk_using_exception then
        raise_application_error(-20003, 'В таблице VISIT_TO_DOC присутствует запись с данным доктором DOC.ID.');
end;

-- 2. Проверка значений всех полей отношения "Пациенты", для которых могут быть определены домены.

create or replace trigger pat_verification_trigger
    before insert or update
    on PAT
    for each row
begin
    if SHORTEN_NAME(:NEW.NAME) = '#############' then
        raise_application_error(-20004, 'Неверный формат ФИО. Пример: Куликов Леонид Андреевич.');
    end if;

    if length(:NEW.PHONE) <> 11 then
        raise_application_error(-20005, 'Номер формат телефона. Пример: 89991546824');
    end if;

    if CUT_POLIS(:NEW.POLIS_NUM) = '###########' then
        raise_application_error(-20006, 'Неверный формат полиса. Длина полиса должна быть равна 16 символам.');
    end if;

    if :NEW.BIRTH_DATE > trunc(sysdate) then
        raise_application_error(-20007, 'Еще не рожденные люди не могут быть пациентами.');
    end if;
end;

-- 3. Если при вводе данных дата поступления не указана, устанавливать текущую дату.

create or replace trigger visit_to_doc_time_trigger
    before insert or update
    on VISIT_TO_DOC
    for each row
begin
    if :NEW.VISIT_TIME is null then
        :NEW.VISIT_TIME := sysdate;
        :NEW.END_VISIT_TIME := sysdate + 1/24;
    end if;
end;

-- 4. При удалении данных о пациенте – перенос этих данных в архив.

create or replace trigger pat_archivation_trigger
    before delete
    on PAT
    for each row
begin
    insert into pats_archive
        values (:OLD.ID, :OLD.NAME, :OLD.SEX, :OLD.BIRTH_DATE, :OLD.POLIS_NUM, :OLD.ADDRESS, :OLD.PHONE);
end;