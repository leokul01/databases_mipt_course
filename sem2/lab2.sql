/*
	Куликов Леонид
	6103
	Вариант 2. БД поликлиники.
*/

/* Л.Р. №2. Создание процедур. */

-- 1. Процедура, выдающая расписание приемов на текущую дату:
/*
    Дата
    врач1	время1	пациент1	,
    время2	пациент2	адрес_пациента
    …
    врач2	время1	пациент1	адрес_пациента
    время2	пациент2	адрес_пациента
*/

create or replace procedure current_schedule is
    cursor popular_doctors(cur_date date) is
        select d.ID as doc_id, d.NAME as doc_name, COUNT(*) as visit_count
        from DOC d join VISIT_TO_DOC v on d.ID = v.DOCTOR
        where trunc(v.VISIT_TIME) = trunc(cur_date) and v.PATIENT is not null
        group by d.ID, d.NAME
        order by visit_count desc;

    cursor visits(doc_id integer, cur_date date) is
        select v.VISIT_TIME as visit_time, v.PATIENT as pat_id, p.NAME as pat_name, p.ADDRESS as pat_addr
        from VISIT_TO_DOC v join PAT p on v.PATIENT = p.ID
        where v.DOCTOR = doc_id and trunc(v.VISIT_TIME) = trunc(cur_date)
        order by v.VISIT_TIME desc;

    flag boolean := false;
    NO_VISITS exception;
begin
    DBMS_OUTPUT.PUT_LINE(trunc(sysdate));
    for p in popular_doctors(sysdate) loop
        DBMS_OUTPUT.PUT_LINE(SHORTEN_NAME(p.doc_name));
        for v in visits(p.doc_id, sysdate)
            loop
                flag := true;
                DBMS_OUTPUT.PUT_LINE(to_char(v.visit_time, 'HH24:MI') || ', '
                                         || SHORTEN_NAME(v.pat_name) || ', '
                                         || v.pat_addr);
            end loop;
    end loop;
    if not flag then
        raise NO_VISITS;
    end if;
exception
    when NO_VISITS then
        DBMS_OUTPUT.PUT_LINE('Приемов на текующую дату нету.');
end;

-- 2. Процедура, выдающая по специализации врача и дате список незанятых приемов.
/*
    Специализация
    ФИО_врача1	время_начала_приема	время_окончания_приема
                время_начала_приема	время_окончания_приема
    …
    ФИО_врача1	время_начала_приема	время_окончания_приема
    …
*/

create or replace procedure get_free_visits(spec DOC.spec%TYPE, dat date) is
    cursor available_doctors(spec DOC.spec%TYPE, dat date) is
        select d.ID as doc_id, d.NAME as doc_name, COUNT(*) as visit_count
        from DOC d join VISIT_TO_DOC v on d.ID = v.DOCTOR
        where d.SPEC = spec and trunc(v.VISIT_TIME) = trunc(dat) and v.PATIENT is null
        group by d.ID, d.NAME
        order by visit_count desc;

    cursor free_visits(doc_id integer, dat date) is
        select v.VISIT_TIME as begin_time, v.END_VISIT_TIME as end_time
        from VISIT_TO_DOC v
        where v.DOCTOR = doc_id and trunc(v.VISIT_TIME) = trunc(dat) and v.PATIENT is null
        order by v.VISIT_TIME desc;

    flag boolean := false;
    NO_VISITS exception;
begin
    DBMS_OUTPUT.PUT_LINE(spec);
    for d in available_doctors(spec, dat) loop
        DBMS_OUTPUT.PUT_LINE(SHORTEN_NAME(d.doc_name));
        for v in free_visits(d.doc_id, dat) loop
            flag := true;
            DBMS_OUTPUT.PUT_LINE(to_char(v.begin_time, 'HH24:MI') || ', '
                                     || to_char(v.end_time, 'HH24:MI'));
        end loop;
    end loop;
    if not flag then
        raise NO_VISITS;
    end if;
exception
    when NO_VISITS then
        DBMS_OUTPUT.PUT_LINE('Незанятых приемов нету.');
end;

-- 3. Процедура, определяющая наступление эпидемии.
/*
    Правило такое: если за последнюю неделю количество заболевших с диагнозами ОРЗ,
    ОРВИ и грипп за каждый следующий день увеличивалось не менее чем на 50% по сравнению
    с предыдущим днем, то эпидемия наступила.
*/

create or replace procedure epidemic_check is
    week_day date;
    bad_cases_count integer;
    previous_bad_cases_count integer := 0;
begin
    week_day := trunc(sysdate) - 8;
    for i in 0..6 loop
        week_day := week_day + 1;
        select COUNT(*) into bad_cases_count
        from VISIT_TO_DOC v
        where trunc(v.VISIT_TIME) = week_day
            and v.PATIENT is not null
            and v.DIAGNOSIS in ('ОРЗ', 'ОРВИ', 'грипп');
        exit when bad_cases_count = 0 or bad_cases_count < 1.5 * previous_bad_cases_count;
        previous_bad_cases_count := bad_cases_count;
        if i = 6 then
            DBMS_OUTPUT.PUT_LINE('Бегите, хлопцы... Эпидемия!');
        end if;
    end loop;
end;
--+
begin
    current_schedule();
    get_free_visits('Конечности', sysdate);
    epidemic_check();
end;
