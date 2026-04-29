use library;
insert into  books (id,name,author,kind) values
	(211 , '三国演义' , '罗贯中' , '历史小说');
    
grant select on library.books to 'student'@'localhost';
revoke select on library.books from 'student'@'localhost';