-- Adding 4 books without translation in the library:
-- So, will need Author and Publisher

-- AUTHORS 

-- first name, last_name, nationality, date_of_birth are the columns of this table
-- we don't know in the moment the date_of_birth, so, we don't will insert anything in this column

INSERT INTO "authors"("first_name", "last_name", "nationality")
VALUES
('Machado de', 'Assis', 'brazilian'),
('José de', 'Alencar', 'brazilian'),
('Dyonelio', 'Machado', 'brazilian');


-- we don't have translators in these books

-- PUBLISHERS

-- We'll ignore "phone_number", "email", "website" and "founded_yer", just the "name" for now

INSERT INTO "publishers"("name")
VALUES
('Objetivo'),
('Ática');

-- finally we can add the books with the foreign key:

-- BOOKS

INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "rating", "location", "publisher_id")
VALUES
('Memórias Póstumas de Brás Cubas', 'portuguese', 'portuguese', 1881, 'brazilian literature', 'novel', 5, 'shelf', 2),
('Dom Casmurro', 'portuguese', 'portuguese', 1899, 'brazilian literature', 'novel', 4.8, 'shelf', 1),
('Iracema', 'portuguese', 'portuguese', 1865, 'brazilian literature', 'novel', 3.9, 'shelf', 1),
('Os Ratos', 'portuguese', 'portuguese', 1935, 'brazilain literature', 'novel', 3.5, 'shelf', 2);

-- AUTHORED

-- Machado de Assis is the author of "Memórias Póstumas" and "Dom Casmurro". "José de Alencar" wrote "Iracema",
-- and "Dyonelio Machado" wrote "Os Ratos"
-- We need to have this association table because we can have books with more than one author

INSERT INTO "authored" ("author_id", "book_id")
VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

-- UPDATE DATABASE 

-- The user might add a book that he already read, so he can update the book just after added it

-- In my case I have already read all the four books, so the update query is easy

UPDATE "books" SET "is_read" = TRUE;

-- LENDS

-- If the user, for instance, wants to lend a book to his friend - let's call him Jake -, then it will be necessary insert rows in the tables "lends" and "books_on_lend"
INSERT INTO "lends" ("borrower_name")
VALUES
('Jake');

INSERT INTO "books_on_lend" ("lend_id", "book_id")
VALUES
(1, 4); -- The user lends the book "Iracema" to Jake

-- The books_on_lend is an association table because the user could lend more than one book

INSERT INTO "lends"("borrower_name")
VALUES
('Mary');

INSERT INTO "books_on_lend" ("lend_id", "book_id")
VALUES
(2, 1),
(2, 2); -- The user lends at same time the books "Memórias Póstumas" and "Dom Casmurro" to Mary

-- When the borrower returns the book, update books_on_lend.return_date, and books.lent will automatically be set to 0

UPDATE "books_on_lend" SET "return_date" = CURRENT_DATE
WHERE "book_id" = 1; -- So, Mary returned "Memórias Póstumas"

-- TRANSACTIONS

-- If the user buys a new book he can update both the books table and the transactions table
-- For instance, the user bought the book "O Cortiço"

INSERT INTO "authors"("first_name", "last_name", "nationality")
VALUES
('Aluísio', 'Azevedo', 'brazilian');

INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "location", "publisher_id")
VALUES
('O Cortiço', 'portuguese', 'portuguese', 1890, 'brazilian literature', 'novel', 'shelf', 1);

INSERT INTO "authored" ("author_id", "book_id")
VALUES
(4, 5);

INSERT INTO "transactions" ("type", "value", "entity_type", "entity_name")
VALUES
('purchase', 15, 'store', 'Amazon');

INSERT INTO "books_in_transaction" ("transaction_id", "book_id")
VALUES
(1, 5);

-- The user can sell books also
-- For instance, the user sold to a friend "Camila" his book "Iracema"

INSERT INTO "transactions" ("type", "value", "entity_type", "entity_name")
VALUES
('sale', 10, 'person', 'Camila');

INSERT INTO "books_in_transaction" ("transaction_id", "book_id")
VALUES
(2, 3);

-- In this database we chose not to delete the books when they are sold, and use a soft deletion marking them as "sold" = 1

-- BORROWS

-- If the user borrows a book from another library or person, the initial steps are the same
-- for example, let's say that the user has borrowed the book "Policarpo Quaresma" from the Municipal Library.

INSERT INTO "authors" ("first_name", "last_name", "nationality")
VALUES
('Lima', 'Barreto', 'brazilian');

INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "rating", "location", "publisher_id", "is_read")
VALUES
('Triste Fim de Policarpo Quaresma', 'portuguese', 'portuguese', 1915, 'brazilian literature', 'novel', 3.3, "shelf", 1, 1);

INSERT INTO "authored" ("author_id", "book_id")
VALUES
(5, 6);

INSERT INTO "borrows" ("entity_type", "entity_name", "fine_per_day")
VALUES
('library', 'Municipal Library', 2);

INSERT INTO "books_on_borrow" ("borrow_id", "book_id", "due_date")
VALUES
(1, 6, '2024-08-14');

-- Due to the use of triggers, the user does not need to worry about updating the status of books, such as "sold", "lent" and "borrowed".
