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


-- we don't have translators in this books

-- PUBLISHERS

-- We'll ignore "phone_number", "email", "website" and "founded_yer", just the "name" for now

INSERT INTO "publishers"("name")
VALUES
('Objetivo'),
('Ática');

-- finally we can add the books with the 2 foreign keys:

-- BOOKS

INSERT INTO "books" ("title", "language", "original_language", "year", "category", "genre", "location", "publisher_id")
VALUES
('Memórias Póstumas de Brás Cubas', 'portuguese', 'portuguese', '1881', 'brazilian literature', 'novel', 'shelf', 2),
('Dom Casmurro', 'portuguese', 'portuguese', '1899', 'brazilian literature', 'novel', 'shelf', 1),
('Iracema', 'portuguese', 'portuguese', '1865', 'brazilian literature', 'novel', 'shelf', 1),
('Os Ratos', 'portuguese', 'portuguese', '1935', 'brazilain literature', 'novel', 'shelf', 2);

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

-- RATINGS

-- The user can add a review or just a rating to the books

INSERT INTO "ratings" ("book_id", "rating")
VALUES
(1, 5),
(2, 4.8),
(3, 3.9),
(4, 3.5);

