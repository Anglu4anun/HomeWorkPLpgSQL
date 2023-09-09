-- 1. Создание таблицы students:

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name TEXT,
    total_score INTEGER
);


--2. Создание таблицы activity_scores:

CREATE TABLE activity_scores (
    student_id INTEGER,
    activity_type TEXT,
    score INTEGER
);


--3. Функция update_total_score:

CREATE FUNCTION update_total_score(student_id INTEGER) RETURNS VOID AS $$
DECLARE
    total INTEGER := 0;
    activity_row RECORD;
BEGIN
    FOR activity_row IN SELECT score FROM activity_scores WHERE student_id = student_id LOOP
        total := total + activity_row.score;
    END LOOP;

    UPDATE students SET total_score = total WHERE id = student_id;
END;
$$ LANGUAGE plpgsql;


--4. Триггер для автоматического вызова функции update_total_score:

--Примеры использования:

-- Вставка нескольких студентов в таблицу students:

INSERT INTO students (name, total_score) VALUES ('John', 0), ('Alice', 0), ('Bob', 0);


-- Вставка записей о баллах за разные виды деятельности в таблицу activity_scores:

INSERT INTO activity_scores (student_id, activity_type, score) VALUES (1, 'Homework', 90), (1, 'Exam', 85), (2, 'Homework', 80);


-- Проверка обновления общего балла каждого студента после вставки баллов:

SELECT * FROM students;


--6. Функция calculate_scholarship:

CREATE FUNCTION calculate_scholarship() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_score >= 90 THEN
        NEW.scholarship := 1000;
    ELSIF NEW.total_score >= 80 AND NEW.total_score < 90 THEN
        NEW.scholarship := 500;
    ELSE
        NEW.scholarship := 0;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--7. Триггер update_scholarship_trigger:

CREATE TRIGGER update_scholarship_trigger BEFORE UPDATE ON activity_scores
FOR EACH ROW EXECUTE FUNCTION calculate_scholarship();


--Протестировать решение можно путем вставки данных о студентах и их баллах за деятельность в таблицу activity_scores. Затем можно проверить, как автоматически обновляется стипендия каждого студента после добавления баллов.

--8. Добавление колонки scholarship в таблицу students:

ALTER TABLE students ADD COLUMN scholarship INTEGER;