-- Adding some books without translation in the library:
-- Author and Publisher information will be needed.

-- add AUTHORS 

-- The columns of this table are: first_name, last_name, nationality and date_of_birth.
-- We don't need the date_of_birth at the moment, so we will leave this column empty.

INSERT INTO "authors"("first_name", "last_name", "nationality")
VALUES
('Machado de', 'Assis', 'brazilian'),
('José de', 'Alencar', 'brazilian'),
('Dyonelio', 'Machado', 'brazilian');

-- add PUBLISHERS

-- We'll ignore "phone_number", "email", "website" and "founded_yer", just the "name" for now.

INSERT INTO "publishers"("name")
VALUES
('Objetivo'),
('Ática');

-- finally we can add the books with the foreign key:

-- add BOOKS

INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "rating", "location", "publisher_id")
VALUES
('Memórias Póstumas de Brás Cubas', 'portuguese', 'portuguese', 1881, 'brazilian literature', 'novel', 5, 'shelf', 2),
('Dom Casmurro', 'portuguese', 'portuguese', 1899, 'brazilian literature', 'novel', 4.8, 'shelf', 1),
('Iracema', 'portuguese', 'portuguese', 1865, 'brazilian literature', 'novel', 3.9, 'shelf', 1),
('Os Ratos', 'portuguese', 'portuguese', 1935, 'brazilain literature', 'novel', 3.5, 'shelf', 2);

-- AUTHORED

-- Machado de Assis is the author of "Memórias Póstumas" and "Dom Casmurro". "José de Alencar" wrote "Iracema",
-- and "Dyonelio Machado" wrote "Os Ratos".
-- We need to have this association table because we can have books with more than one author.

INSERT INTO "authored" ("author_id", "book_id")
VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

-- UPDATE DATABASE 

-- The user can update the row corresponding to one of the books they have read, marking it as 'is_read'.

UPDATE "books" SET "is_read" = TRUE
WHERE "title" = 'Dom Casmurro';

-- add LENDS

-- If the user, for instance, wants to lend a book to his friend - let's call him Jake -, 
-- it will be necessary insert rows in the 'loans' and 'books_on_loan' tables.

INSERT INTO "loans" ("type", "loaner_type", "loaner_name") -- loan_date is set by default to the current datetime
VALUES
('lend', 'person', 'Jake');

INSERT INTO "books_on_loan" ("loan_id", "book_id")
VALUES
(1, 4); -- The user lends the book "Os Ratos" to Jake.

-- The 'books_on_loan' table is an association table because the user can loan more than one book at the same time.

INSERT INTO "loans"("type", "loaner_type", "loaner_name")
VALUES
('lend', 'person', 'Mary');

INSERT INTO "books_on_loan" ("loan_id", "book_id")
VALUES
(2, 1),
(2, 2); -- The user lends the books "Memórias Póstumas" and "Dom Casmurro" to Mary at the same time.

-- When the borrower returns the book, it will be necessary to update the 'return_date' in the 'books_on_lend' table.
-- Then the 'lent' column in the 'books' table will automatically be set to 0 due to the triggers.

UPDATE "books_on_loan" SET "return_date" = CURRENT_DATE
WHERE "book_id" = 1; -- So, Mary returned 'Memórias Póstumas' but kept 'Dom Casmurro.

-- add TRANSACTIONS

-- If the user buys a new book, they can update both the 'books' table and the 'transactions' table.
-- For instance, the user bought the book 'O Cortiço'.

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

-- The user can also sell books.
-- For instance, the user sold their book 'Iracema' to their friend Camila.

INSERT INTO "transactions" ("type", "value", "entity_type", "entity_name")
VALUES
('sale', 10, 'person', 'Camila');

INSERT INTO "books_in_transaction" ("transaction_id", "book_id")
VALUES
(2, 3);

-- In this database we chose not to delete the books when they are sold, and use a soft deletion marking them as "sold" = TRUE,
-- which is automatically updated by the triggers

-- add BORROWS

-- If the user borrows a book from another library or person, the initial steps are the same
-- for example, let's say that the user has borrowed the book "Policarpo Quaresma" from the Municipal Library.

-- first adds the book
INSERT INTO "authors" ("first_name", "last_name", "nationality")
VALUES
('Lima', 'Barreto', 'brazilian');

-- second the author
INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "rating", "location", "publisher_id", "is_read")
VALUES
('Triste Fim de Policarpo Quaresma', 'portuguese', 'portuguese', 1915, 'brazilian literature', 'novel', 3.3, 'shelf', 1, 1);

-- adds in the association table
INSERT INTO "authored" ("author_id", "book_id")
VALUES
(5, 6);

-- finally adds the borrow
INSERT INTO "loans" ("type", "loaner_type", "loaner_name", "fine_per_day")
VALUES
('borrow', 'library', 'Municipal Library', 2);

INSERT INTO "books_on_loan" ("loan_id", "book_id", "due_date")
VALUES
(3, 6, '2024-08-14');

-- Due to the use of triggers, the user does not need to worry about updating the status of books,
-- such as "sold", "lent" and "borrowed".

-- SELECT 

-- Some common queries that users might make can be simplified thanks to the Views.

-- Search books that have been sold
SELECT * FROM "sold_books";

-- Search books that have been lent
SELECT * FROM "lent_books";

-- Search books that have been borrowed and haven't been returned yet
SELECT * FROM "current_borrowed_books";

-- Search books that are on the shelf
SELECT * FROM "books_on_shelf";

-- Search books that are on the kindle
SELECT * FROM "books_on_kindle";

-- Search books that have already been read
SELECT * FROM "been_read";

-- Search books by a specific author
SELECT * FROM "books"
JOIN "authored" ON "authored"."book_id" = "books"."id"
JOIN "authors" ON "authored"."author_id" = "authors"."id"
WHERE "authors"."last_name" = 'Machado';

-- Check loans for a specific book
SELECT "lends".*, "books"."title" 
FROM "books_on_lend"
JOIN "lends" ON "books_on_lend"."lend_id" = "lends"."id"
JOIN "books" ON "books_on_lend"."book_id" = "books"."id"
WHERE "books"."id" = 1;
