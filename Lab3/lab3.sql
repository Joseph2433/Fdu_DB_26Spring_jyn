drop database if exists library;
create database if not exists library;

use library;

create table students (
	id int primary key,
    name varchar(50) not null,
    age int not null check (age in (18, 19, 20, 21, 22, 23)),
    gender varchar(10) not null
    );
    
create table books(
	id int primary key,
    name varchar(100) not null,
    author varchar(50) not null,
    kind varchar(50) not null
    );
    
    
create table borrow (
	borrow_id INT AUTO_INCREMENT PRIMARY KEY, 
    student_id int not null,
    book_id int not null,
    borrow_time date not null,
    return_time date,
    foreign key (student_id) references students(id),
    foreign key (book_id) references books(id)
    );
    
INSERT INTO students (id, name, age, gender) VALUES 
	(1001, '李明', 18, '男'),
	(1002, '李华', 19, '女'),
	(1003, '方源', 22, '男'),
	(1004, '萧炎', 21, '男'),
	(1005, '林动', 23, '男'),
	(1006, '小舞', 19, '女'),
	(1007, '唐三', 20, '男'),
	(1008, '故障机器人', 19, '女'),
	(1009, 'Lucy', 22, '女'),
	(1010, 'Jack', 21, '男');
    
INSERT INTO books (id, name, author, kind) VALUES 
	(201, '三体', '刘慈欣', '科幻'),
	(202, '解忧杂货店', '东野圭吾', '悬疑'),
	(203, '活着', '余华', '文学'),
	(204, 'Python编程从入门到实践', 'Eric Matthes', '计算机'),
	(205, '百年孤独', '马尔克斯', '文学'),
	(206, '明朝那些事儿', '当年明月', '历史'),
	(207, '高等数学', '同济大学', '教材'),
	(208, '蛊真人', '蛊真人', '猎奇'),
	(209, '红楼梦', '曹雪芹', '文学'),
	(210, '数据库系统概论', '王珊', '计算机');

INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1001, 201, '2023-10-01', '2023-10-15'),
	(1001, 204, '2023-11-01', NULL),
	(1002, 202, '2023-10-05', '2023-10-20'),
	(1003, 203, '2023-11-10', '2023-11-15'),
	(1004, 206, '2023-10-12', '2023-10-25'),
	(1005, 205, '2023-11-15', NULL),
	(1006, 207, '2023-11-20', '2023-11-22'),
	(1007, 208, '2023-12-01', NULL),
	(1008, 209, '2023-12-05', '2023-12-20'),
	(1009, 210, '2023-12-10', NULL),
    (1007, 207, '2023-11-24', NULL),
    (1004, 203, '2023-11-18', NULL);
    
describe students;
select * from students;

describe books;
select * from books;

describe borrow;
select * from borrow;

-- part2 --
select id , name
from students
where id not in(
	select student_id from borrow br
    join books bk on br.book_id = bk.id
    where bk.name = '蛊真人'
    );

select distinct bk.name
from books bk
join borrow br on bk.id = br.book_id 
where br.student_id in (
	select sub_br.student_id from books sub_bk
	join borrow sub_br on sub_bk.id = sub_br.book_id 
	where sub_bk.name = '高等数学'
    );

select st.name, st.gender
from students st
join borrow br on st.id = br.student_id
group by st.id
having count(br.book_id) >= 2;

select bk.name
from books bk 
where bk.id not in(
	select borrow.book_id
    from borrow join students on borrow.student_id = students.id
    where students.name = '唐三'
    );
    
select distinct st.id, st.name
from students st
join borrow br on st.id = br.student_id
where exists (
	select 1
	from students sub_st
	join borrow sub_br on sub_st.id = sub_br.student_id
	where sub_st.name = '唐三' and sub_br.book_id = br.book_id) and st.name <> '唐三';
    
SELECT st.name
FROM students st
WHERE 
NOT EXISTS (
    SELECT br1.book_id FROM borrow br1
    JOIN students s1 ON br1.student_id = s1.id
    WHERE s1.name = '方源'
    AND br1.book_id NOT IN (
        SELECT br2.book_id FROM borrow br2 
        WHERE br2.student_id = st.id
    )
)
AND 
NOT EXISTS (
    SELECT br3.book_id FROM borrow br3
    WHERE br3.student_id = st.id
    AND br3.book_id NOT IN (
        SELECT br4.book_id FROM borrow br4
        JOIN students s2 ON br4.student_id = s2.id
        WHERE s2.name = '方源'
    )
);

select distinct st.name
from students st ,(SELECT id, age FROM students WHERE name = '方源') AS fy
where st.id > fy.id and st.age < fy.age;

SELECT name, age
FROM students
WHERE name LIKE 'L%';
	
select name ,age
from students 
where gender = '男' and age > (select avg(age) from students where gender = '女') ;

select name ,age
from students 
where gender = '男' and age < all(select age from students where gender = '女') ;

INSERT INTO students (id, name, age, gender) VALUES 
	(1001 , 'Lily' , 20 , '女');

INSERT INTO students (id, name, age, gender) VALUES 
	(1020 , 'Lily' , 10 , '女');
    
update borrow
set student_id = 1030
where student_id = 1001;

INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1040, 201, '2023-10-01', '2023-10-15');
    
INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1001, 291, '2023-10-01', '2023-10-15');
   
DELIMITER //
create trigger insert_check before insert on borrow
for each row
begin 
	declare current_count int;
    
    select count(student_id) into current_count
    from borrow
    where student_id = new.student_id;
    
    if current_count >= 3 then
		signal sqlstate '45000'
        set message_text  = '错误：该学生借书数量已达上限（3本），禁止继续借阅！';
    end if;
end //
DELIMITER 


INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1001, 204, '2024-10-01', NULL);
    
INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1001, 205, '2024-10-02', NULL);
    
	

