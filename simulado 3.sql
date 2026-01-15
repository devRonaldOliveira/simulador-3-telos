create database biblioteca_telos ;

use biblioteca_telos;

create table books (
book_id int auto_increment primary key,
title varchar (100) not null,
author varchar (100) not null,
genre varchar(100) not null,
published_year int
);

create table users (
user_id int auto_increment primary key,
name varchar (100) not null,
email varchar(100) not null
);

CREATE TABLE loans (
loan_id INT AUTO_INCREMENT PRIMARY KEY, 
loan_date DATE NOT NULL,
return_date DATE,
book_id INT,
user_id INT,
CONSTRAINT fk_book_loan 
 FOREIGN KEY (book_id) REFERENCES books(book_id),
        
CONSTRAINT fk_user_loan 
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- gerenciamento de users 

INSERT INTO users (name, email) VALUES 
('Ana Silva', 'ana.silva@email.com'),
('Bruno Oliveira', 'bruno.o@email.com'),
('Carla Souza', 'carla.souza@email.com'),
('Diego Santos', 'diego.s@email.com'),
('Elena Pires', 'elena.pires@email.com'),
('Fabio Melo', 'fabio.m@email.com'),
('Gisele Ramos', 'gisele.r@email.com'),
('Helio Costa', 'helio.c@email.com'),
('Igor Vaz', 'igor.vaz@email.com'),
('Julia Lima', 'julia.lima@email.com');

-- atualizando informação de usuarios
update users 
set name = 'ana silva rocha', email = 'ana.novoEmail@email.com'
where user_id = 1;

DELETE FROM loans WHERE user_id = 5;  -- Deletando primeiro a FK 

DELETE FROM users WHERE user_id = 5;

SELECT name, email 
FROM users 
WHERE name LIKE '%Bruno%';

-- GERENCIAMENTO DE LIVROS
INSERT INTO books (title, author, genre, published_year) VALUES 
('O Domo', 'Stephen King', 'Ficção Científica', 2009),
('Dom Casmurro', 'Machado de Assis', 'Clássico', 1909),
('O Hobbit', 'J.R.R. Tolkien', 'Fantasia', 1937),
('1984', 'George Orwell', 'Distopia', 1949),
('A Hora da Estrela', 'Clarice Lispector', 'Literatura Brasileira', 1977),
('Sapiens', 'Yuval Noah Harari', 'História', 2011),
('O Alquimista', 'Paulo Coelho', 'Autoajuda', 1988),
('O Iluminado', 'Stephen King', 'Terror', 1977),
('Fundação', 'Isaac Asimov', 'Ficção Científica', 1951),
('Ensaio sobre a Cegueira', 'José Saramago', 'Ficção', 1995);

UPDATE BOOKS 
set title = 'O DOMO', published_year = '2009'
where book_id = 1;

DELETE FROM books 
WHERE book_id = 5;	

SELECT title, author, genre 
FROM books 
WHERE title LIKE '%Domo%';

-- GERENCIAMENTO DE EMPRESTIMOS
INSERT INTO loans (loan_date, return_date, book_id, user_id) VALUES 
('2024-01-10', '2024-01-25', 1, 1),
('2024-01-12', '2024-01-27', 2, 2),
('2024-02-01', '2024-02-15', 3, 3),
('2024-02-05', NULL, 4, 4), 
('2024-03-10', '2024-03-25', 6, 6),
('2024-03-15', NULL, 1, 6), 
('2024-04-01', '2024-04-10', 7, 7),
('2024-04-05', '2024-04-20', 8, 8),
('2024-05-01', NULL, 9, 9),
('2024-05-10', NULL, 10, 10);

UPDATE loans 
SET return_date = '2024-04-03' 
WHERE loan_id = 4; 

select * from loans;

DELIMITER $$
CREATE PROCEDURE realizar_emprestimo(IN p_book_id INT, IN p_user_id INT)
BEGIN
    -- Verifica se o livro está com algum empréstimo
    IF EXISTS (SELECT 1 FROM loans WHERE book_id = p_book_id AND return_date IS NULL) THEN
        SELECT 'Este livro já está emprestado no momento.' AS Mensagem;
    ELSE
        
        INSERT INTO loans (loan_date, book_id, user_id) 
        VALUES (CURDATE(), p_book_id, p_user_id);
        
        SELECT 'Empréstimo registrado com sucesso!' AS Mensagem;
    END IF;
END $$
DELIMITER ;

-- veficiando disponibilidade do livro 
CALL realizar_emprestimo(3, 1);

CALL realizar_emprestimo(4,6);

-- relatorio de livros emprestados e devolvidos
SELECT 
    b.title AS Livro,
    u.name AS Usuario,
    l.loan_date AS Data_Emprestimo,
    IFNULL(l.return_date, 'Em aberto') AS Status_Devolucao
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN users u ON l.user_id = u.user_id
ORDER BY l.loan_date DESC;

--  relatorio de livros emprestados 
SELECT 
    b.title AS Titulo_do_Livro,
    u.name AS Nome_do_Usuario,
    l.loan_date AS Data_da_Retirada
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN users u ON l.user_id = u.user_id
WHERE l.return_date IS NULL;

-- relatorio de usuarios com mais emprestimos .
SELECT 
    u.name AS Usuario,
    COUNT(l.loan_id) AS Total_de_Emprestimos
FROM users u
LEFT JOIN loans l ON u.user_id = l.user_id
GROUP BY u.user_id, u.name
ORDER BY Total_de_Emprestimos DESC;

-- função para conta total de emprestimos por usuarios
DELIMITER $$
CREATE FUNCTION TotalLoans(p_user_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(*) INTO total 
    FROM Loans 
    WHERE user_id = p_user_id;
    
    RETURN total;
END $$
DELIMITER ;

SELECT 
    user_id, 
    name, 
    email, 
    TotalLoans(user_id) AS total_de_emprestimos
FROM Users;

-- Relatorio para identificar usuarios com mais de 3 emprestimos
SELECT 
    name, 
    (SELECT COUNT(*) FROM Loans WHERE Loans.user_id = Users.user_id) AS quantidade_livros
FROM Users
WHERE (SELECT COUNT(*) FROM Loans WHERE Loans.user_id = Users.user_id) > 1;




