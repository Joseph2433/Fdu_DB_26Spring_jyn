CREATE USER 'teacher'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'student'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON library.* TO 'teacher'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

SELECT user, host FROM mysql.user;
SHOW GRANTS FOR 'teacher'@'localhost';
SHOW GRANTS FOR 'student'@'localhost';

create view all_books_name as
	select name 
    from books;
    
grant select on all_books_name to 'student'@'localhost';