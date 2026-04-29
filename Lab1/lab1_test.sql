show tables;

describe courses_selection;

alter table  students  add address varchar(50);

describe students;

select * from students;

select * from courses;

select * from courses_selection;

insert into students (id , name, age ,gender)

values
	(1,'Tom',20,'Male'),
    (2,'Jane',21,'FeMale'),
    (3,'Bob',22,'Male'),
    (4,'Alice',23,'FeMale');
    
    
insert into courses (id , name, credit)

values
	(1,'Math',3),
    (2,'English',2),
    (3,'Physics',4),
    (4,'Chemistry',3);


load data infile 'E:/MySQL/MySQL Server 8.0/Uploads/students.txt'
into table students
fields terminated by ','
lines terminated by '\n'
(id,name,gender,address);

show variables like 'secure_file_priv';

update students
set address = '456 Oak St'
where name = 'Alice';

set sql_safe_updates = 0;

insert into students(id,name,age,gender) 
value('100','temp','15','F');

delete from students
where name = 'temp';

-- 向 "course_selection" 表格中插入数据
INSERT INTO courses_selection (id, student_id, course_id, selection_time)
VALUES
    (1, 1, 1, '2022-09-01 10:00:00'),
    (2, 1, 2, '2022-09-02 11:00:00'),
    (3, 2, 1, '2022-09-03 12:00:00'),
    (4, 2, 2, '2022-09-04 13:00:00'),
    (5, 3, 3, '2022-09-05 14:00:00'),
    (6, 3, 4, '2022-09-06 15:00:00'),
    (7, 4, 1, '2022-09-07 16:00:00');

select id,age
from students
where name = 'Alice';

select avg(age) AS avg_age
from students;

select name, age
from students
order by age asc
limit 5;

select * from students;

select gender , Avg(age) as avg_age
from students
group by gender;

select id,age 
from students
where age > 20 and age < 25;

select students.name as student_name , courses.name as course_name
from students,courses,courses_selection
where students.id = courses_selection.student_id
and courses.id = courses_selection.course_id;

select name
from students
where id in (
	select student_id
    from courses_selection
    where course_id = (
		select id
        from courses
        where name = "Math")
        );


select gender , count(*)
from students
where id in (select distinct student_id
	from courses_selection
    ) group by gender;

SELECT 
    s.name AS student_name, 
    c.name AS courses_names
FROM courses_selection cs
JOIN students s ON s.id = cs.student_id
JOIN courses c ON c.id = cs.course_id;
