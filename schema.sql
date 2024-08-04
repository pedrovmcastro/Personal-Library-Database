-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- TABLES 

CREATE TABLE "authors" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "nationality" TEXT,
    "date_of_birth" DATE,
    PRIMARY KEY("id")
);

CREATE TABLE "translators" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "nationality" TEXT,
    "date_of_birth" DATE,
    PRIMARY KEY("id")
);

CREATE TABLE "publishers" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "founded_year" INTEGER,
    "phone_number" TEXT,
    "email" TEXT,
    "website" TEXT,
    PRIMARY KEY("id")
);

CREATE TABLE "books" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "original_language" TEXT NOT NULL,
    "year" INTEGER,
    "edition" INTEGER,
    "edition_year" INTEGER,
    "category" TEXT NOT NULL,
    "genre" TEXT NOT NULL,
    "rating" NUMERIC CHECK("rating" BETWEEN 0 AND 5),
    "location" TEXT, -- shelf, kindle, etc...
    "is_read" BOOLEAN DEFAULT FALSE,
    "sold" BOOLEAN DEFAULT FALSE,
    "lent" BOOLEAN DEFAULT FALSE,
    "borrowed" BOOLEAN DEFAULT FALSE,
    "translator_id" INTEGER,
    "publisher_id" INTEGER,
    FOREIGN KEY("translator_id") REFERENCES "translators"("id"),
    FOREIGN KEY("publisher_id") REFERENCES "publishers"("id"),
    PRIMARY KEY("id")
);

-- Association table authors-book
CREATE TABLE "authored" (
    "author_id" INTEGER NOT NULL, 
    "book_id" INTEGER NOT NULL,
    PRIMARY KEY("author_id", "book_id"),
    FOREIGN KEY("author_id") REFERENCES "authors"("id"),
    FOREIGN KEY("book_id") REFERENCES "books"("id")
);

CREATE TABLE "transactions" (
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN ('purchase', 'sale')),
    "value" NUMERIC NOT NULL,
    "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'store')),
    "entity_name" TEXT NOT NULL,
    "contact" TEXT, -- phone number or email
    PRIMARY KEY("id")
);

-- Association table books-transaction
CREATE TABLE "books_in_transaction" (
    "transaction_id" INTEGER NOT NULL,
    "book_id" INTEGER NOT NULL,
    FOREIGN KEY ("transaction_id") REFERENCES "transactions"("id"),
    FOREIGN KEY ("book_id") REFERENCES "books"("id"),
    PRIMARY KEY ("transaction_id", "book_id")
);

CREATE TABLE "lends" (
    "id" INTEGER,
    "lend_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "borrower_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Association table books-lend
CREATE TABLE "books_on_lend" (
    "lend_id" INTEGER,
    "book_id" INTEGER,
    "due_date" DATE, -- Each book can have its own due and return date.
    "return_date" DATE,
    FOREIGN KEY ("lend_id") REFERENCES "lends"("id"),
    FOREIGN KEY ("book_id") REFERENCES "books"("id"),
    PRIMARY KEY ("lend_id", "book_id")
);

CREATE TABLE "borrows" (
    "id" INTEGER,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'library')),
    "entity_name" TEXT NOT NULL,
    "borrow_date" DATE DEFAULT CURRENT_DATE,
    "due_date" DATE, -- It can be null because with people you generally don't have a due date.
    "return_date" DATE,
    "fine_per_day" NUMERIC CHECK("fine_per_day" >= 0 AND "fine_per_day" = ROUND("fine_per_day", 2)) DEFAULT 0,
    "total_fine" NUMERIC CHECK("total_fine" >= 0 AND "total_fine" = ROUND("total_fine", 2)) DEFAULT 0,
    PRIMARY KEY("id")
);

-- Association table books-borrow
CREATE TABLE "books_on_borrow" (
    "borrow_id" INTEGER,
    "book_id" INTEGER,
    FOREIGN KEY ("borrow_id") REFERENCES "borrows"("id"),
    FOREIGN KEY ("book_id") REFERENCES "books"("id"),
    PRIMARY KEY ("borrow_id", "book_id")
);

-- VIEWS

-- To view all books in the library
CREATE VIEW "all_books" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "location"       
FROM "books"
WHERE "location" = 'shelf' OR "location" = 'kindle'
ORDER BY "location", "author", "year";

-- To view all books on the shelf
CREATE VIEW "books_on_shelf" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "location"       
FROM "books"
WHERE "location" = 'shelf'
ORDER BY "author", "year";

-- To view all books in the kindle
CREATE VIEW "books_on_kindle" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "location"       
FROM "books"
WHERE "location" = 'kindle'
ORDER BY "author", "year";

-- To view all books that have already been read
CREATE VIEW "been_read" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "location"       
FROM "books"
WHERE "is_read" = TRUE
ORDER BY "location", "author";

-- To view all books that were borrowed
CREATE VIEW "borrowed_books" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "borrow_id", "entity_name" AS "lender", "borrow_date", "due_date", "total_fine"   
FROM "books"
JOIN "books_on_borrow" ON "books_on_borrow"."book_id" = "books"."id"
JOIN "borrows" ON "borrows"."id" = "books_on_borrow"."borrow_id"
WHERE "borrowed" = TRUE
ORDER BY "due_date", "borrow_date";

-- To view all books that were lent
CREATE VIEW "lent_books" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "lend_id", "borrower_name" AS "borrower", "lend_date", "due_date"      
FROM "books"
JOIN "books_on_lend" ON "books_on_lend"."book_id" = "books"."id"
JOIN "lends" ON "lends"."id" = "books_on_lend"."lend_id"
WHERE "lent" = TRUE
ORDER BY "due_date", "lend_date";

-- To view all books that were sold (soft deletion)
CREATE VIEW "sold_books" AS
SELECT 
    "title", "year",
    (SELECT "first_name" || ' ' || "last_name"
    FROM "authors"
    JOIN "authored" ON "authored"."author_id" = "authors"."id"
    WHERE "authored"."book_id" = "books"."id"
    ORDER BY "authors"."last_name" LIMIT 1) AS "author",
    "language", "rating", "transaction_id", "entity_name" AS "buyer", "value", "timestamp"   
FROM "books"
JOIN "books_in_transaction" ON "books_in_transaction"."book_id" = "books"."id"
JOIN "transactions" ON "transactions"."id" = "books_in_transaction"."transaction_id"
WHERE "sold" = TRUE
ORDER BY "timestamp";

-- TRIGGERS

-- Trigger to update books.sold to TRUE when a new sale transaction is inserted
CREATE TRIGGER "sold"
AFTER INSERT ON "books_in_transaction"
FOR EACH ROW
WHEN (SELECT "type" FROM "transactions" WHERE "id" = NEW."transaction_id") = 'sale'
BEGIN
    UPDATE "books"
    SET "sold" = TRUE, "location" = 'sold'
    WHERE "id" = NEW."book_id";
END;

-- Trigger to update books.sold to FALSE when a new purchase transaction is inserted for a book that was already sold
CREATE TRIGGER "bought"
AFTER INSERT ON "books_in_transaction"
FOR EACH ROW
WHEN (SELECT "type" FROM "transactions" WHERE "id" = NEW."transaction_id") = 'purchase'
BEGIN
    UPDATE "books", "location" = 'shelf'
    SET "sold" = FALSE
    WHERE "id" = NEW."book_id";
END;

-- Trigger to update books.lent to TRUE when a new lend is inserted
CREATE TRIGGER "lent"
AFTER INSERT ON "books_on_lend"
FOR EACH ROW
BEGIN
    UPDATE "books"
    SET "lent" = TRUE, "location" = 'lent'
    WHERE "id" = NEW."book_id";
END;

-- Trigger to update books.lent to FALSE when a lent book is returned to the user
CREATE TRIGGER "lend_returned"
AFTER UPDATE OF "return_date" ON "books_on_lend"
FOR EACH ROW
BEGIN
    UPDATE "books"
    SET "lent" = FALSE, "location" = 'shelf'
    WHERE "id" = NEW."book_id";
END;
    
-- Trigger to update books.borrowed to TRUE when a new borrow is inserted
CREATE TRIGGER "borrowed"
AFTER INSERT ON "borrows"
FOR EACH ROW
BEGIN
    UPDATE "books"
    SET "borrowed" = TRUE
    WHERE "id" IN (
        SELECT "book_id"
        FROM "books_on_borrow"
        WHERE "borrow"."id" = NEW."id"
    );
END;

-- A QUESTÃO DA MULTA DA BIBLIOTECA PODE SER UMA FEATURE PARA A VERSÃO 1.1 E dai voce diz isso no design.md
-- uma outra escolha que voce no momento pensa em não implementar, registrar as entregas... tanto dos lends (quando te devolvem o livro que vc emprestou)
-- quanto no borrow (quando vc devolve o livro que pegou emprestado, seja de uma pessoa ou de uma outra biblioteca) dai aplicar as multas baseado nas diferenças das datas

-- INDEXES

-- To optmize this database is created indexes, to order the data allowing binary search; 
-- much faster than linear search in unordered data.
-- The queries will bring the answers faster.

CREATE INDEX "books_index" ON "books"("id");

CREATE INDEX "title_index" ON "books"("title");

CREATE INDEX "books_location_index" ON "books"("location");

CREATE INDEX "authors_index" ON "authors"("id");

CREATE INDEX "authors_last_name_index" ON "authors"("last_name");

CREATE INDEX "transactions_index" ON "transactions"("id");

