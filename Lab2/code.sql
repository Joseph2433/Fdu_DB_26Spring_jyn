drop database if exists library;
create database if not exists library;

use library;

create table students (
	id int primary key,
    name varchar(50) not null,
    age int not null,
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
    borrow_time varchar(50) not null,
    return_time varchar(50),
    foreign key (student_id) references students(id),
    foreign key (book_id) references books(id)
    );
    
INSERT INTO students (id, name, age, gender) VALUES 
	(1001, '李明', 20, '男'),
	(1002, '李华', 19, '女'),
	(1003, '方源', 22, '男'),
	(1004, '萧炎', 21, '女'),
	(1005, '林动', 23, '男'),
	(1006, '小舞', 18, '女'),
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
	(208, '线性代数', '同济大学', '教材'),
	(209, '红楼梦', '曹雪芹', '文学'),
	(210, '数据库系统概论', '王珊', '计算机');

INSERT INTO borrow (student_id, book_id, borrow_time, return_time) VALUES 
	(1001, 201, '2023-10-01', '2023-10-15'),
	(1001, 204, '2023-11-01', NULL),
	(1002, 202, '2023-10-05', '2023-10-20'),
	(1003, 203, '2023-11-10', NULL),
	(1004, 206, '2023-10-12', '2023-10-25'),
	(1005, 205, '2023-11-15', NULL),
	(1006, 207, '2023-11-20', NULL),
	(1007, 208, '2023-12-01', NULL),
	(1008, 209, '2023-12-05', '2023-12-20'),
	(1009, 210, '2023-12-10', NULL);
     
select name , age , gender
from students
order by age desc; 

SET sql_safe_updates = 0;
update books
set kind = 'hello world joseph!'
where book_name = 'Python编程从入门到实践';

alter table students add telephone varchar(50);

update students
set telephone = '19912344321'
where name = '张三';

select name ,gender ,age 
from students
where(gender,age) in(
	select gender ,min(age)
    from students
    group by gender
    );
    
delete from borrow
where student_id in (
	select id
    from students
    where age > 18
    );
    
select book_name 
from books
where book_id in (
	select book_id from borrow
    where student_id in (
		select id from students
        where name = '王五'));
        
update borrow
set return_time = '2026-03-01'
where student_id in (
	select id from students
    where name = '孙七');
    
update students
set age = age + 2
where id in (
	select student_id from borrow
	where book_id = '203');
    
select
	s.name as '姓名',
	bk.book_name as '书名',
    b.return_time as '归还时间'
from borrow b
join students s on b.student_id = s.id
join books bk on b.book_id = bk.book_id;

     
describe students;
select * from students;

describe books;
select * from books;

describe borrow;
select * from borrow;
