-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it
CREATE TABLE "authors" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "nationality" TEXT NOT NULL,
    "date_of_birth" DATE,
    PRIMARY KEY("id")
);

CREATE TABLE "translators" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "nationality" TEXT NOT NULL,
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
    PRIMARY KEY("id"),
    FOREIGN KEY("address_id") REFERENCES "addresses"("id")
);

CREATE TABLE "ratings" (
    "id" INTEGER,
    "rating" NUMERIC NOT NULL CHECK("rating" BETWEEN 0 AND 5),
    "review" TEXT,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

CREATE TABLE "books" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "original_language" TEXT NOT NULL,
    "year" INTEGER NOT NULL,
    "edition" INTEGER,
    "edition_year" INTEGER,
    "category" TEXT NOT NULL,
    "genre" TEXT NOT NULL,
    "location" TEXT, -- shelf, kindle, etc...
    "is_read" BOOLEAN DEFAULT FALSE,
    "sold" BOOLEAN DEFAULT FALSE,
    "lent" BOOLEAN DEFAULT FALSE,
    "borrowed" BOOLEAN DEFAULT FALSE,
    "translator_id" INTEGER,
    "publisher_id" INTEGER,
    "rating_id" INTEGER,
    FOREIGN KEY("translator_id") REFERENCES "translators"("id"),
    FOREIGN KEY("publisher_id") REFERENCES "publishers"("id"),
    FOREIGN KEY("rating_id") REFERENCES "ratings"("id"),
    PRIMARY KEY("id")
);

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
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'store')),
    "entity_name" TEXT NOT NULL,
    "contact" TEXT,
    PRIMARY KEY("id"),
);

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
    "return_date" DATE,
    "borrower_name" TEXT NOT NULL,
    PRIMARY KEY("id"),
);

CREATE TABLE "books_on_lend" (
    "lend_id" INTEGER,
    "book_id" INTEGER,
    FOREIGN KEY ("lend_id") REFERENCES "lends"("id"),
    FOREIGN KEY ("book_id") REFERENCES "books"("id"),
    PRIMARY KEY ("lend_id", "book_id")
);

CREATE TABLE "borrows" (
    "id" INTEGER,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'library')),
    "entity_name" TEXT NOT NULL,
    "borrow_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "due_date" DATE, -- It can be null because with people you generally don't have a due date.
    "fine_per_day" NUMERIC CHECK("fine" >= 0 AND "fine" = ROUND("fine", 2)) DEFAULT 0,
    "total_fine" NUMERIC CHECK("fine" >= 0 AND "fine" = ROUND("fine", 2)) DEFAULT 0,
    "return_date" DATE,
    PRIMARY KEY("id"),
);

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
SELECT "title", "year", "language", "location", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
ORDER BY "location", "title";

-- To view all books on the shelf
CREATE VIEW "shelf" AS
SELECT "title", "year", "language", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author" 
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "location" = 'shelf',
ORDER BY "title";

-- To view all books in the kindle
CREATE VIEW "kindle" AS
SELECT "title", "year", "language", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"    
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "location" = 'kindle',
ORDER BY "title";

-- To view all books that have already been read
CREATE VIEW "been_read" AS
SELECT "title", "year", "language", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "is_read" = TRUE,
ORDER BY "title";

-- To view all books that were borrowed
CREATE VIEW "borrowed_books" AS
SELECT "title", "year", "language" , "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "borrowed" = TRUE,
ORDER BY "title";

-- To view all books that were lent
CREATE VIEW "lent_books" AS
SELECT "title", "year", "language", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "lent" = TRUE,
ORDER BY "title";

-- To view all books that were sold (soft deletion)
CREATE VIEW "sold_books" AS
SELECT "title", "year", "language", "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author"    
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "sold" = TRUE,
ORDER BY "title";