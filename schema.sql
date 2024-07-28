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
)

CREATE TABLE "addresses" (
    "id" INTEGER,
    "street" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "postal_code" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "publishers" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "founded_year" INTEGER,
    "phone_number" TEXT,
    "email" TEXT,
    "website" TEXT,
    "address_id" INTEGER,
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
    "bilingual_edition" BOOLEAN DEFAULT FALSE,
    "year" INTEGER NOT NULL,
    "edition" INTEGER NOT NULL,
    "edition_year" INTEGER,
    "category" TEXT NOT NULL,
    "genre" TEXT NOT NULL,
    "location" TEXT NOT NULL, -- shelf, kindle, etc...
    "is_read" BOOLEAN DEFAULT FALSE,
    "sold" BOOLEAN DEFAULT FALSE,
    "lent" BOOLEAN DEFAULT FALSE,
    "borrowed" BOOLEAN DEFAULT FALSE,
    "translator_id" INTEGER,
    "publisher_id" INTEGER NOT NULL,
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

CREATE TABLE "people" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "address_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("address_id") REFERENCES "addresses"("id")
);

CREATE TABLE "stores" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "phone_number" TEXT,
    "email" TEXT,
    "website" TEXT,
    "address_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("address_id") REFERENCES "addresses"("id")
);

CREATE TABLE "libraries" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "phone_number" TEXT,
    "email" TEXT,
    "website" TEXT,
    "address_id" INTEGER,
    "fine" NUMERIC NOT NULL CHECK("fine" > 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("address_id") REFERENCES "addresses"("id")
);

CREATE TABLE "transactions" (
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN ('purchase', 'sale')),
    "value" NUMERIC NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'store')),
    "store_id" INTEGER,
    "person_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY ("store_id") REFERENCES "stores"("id"),
    FOREIGN KEY ("person_id") REFERENCES "people"("id"),
    CHECK (
        ("entity_type" = 'store' AND "store_id" IS NOT NULL AND "person_id" IS NULL)
        OR
        ("entity_type" = 'person' AND "person_id" IS NOT NULL AND "store_id" IS NULL)
    )
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
    "borrower_id" INTEGER NOT NULL,
    "lend_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "return_date" DATE,
    PRIMARY KEY("id"),
    FOREIGN KEY("borrower_id") REFERENCES "people"("id")
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
    "lender_id" INTEGER,
    "library_id" INTEGER,
    "entity_type" TEXT NOT NULL CHECK("entity_type" IN ('person', 'library')),
    "borrow_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "due_date" DATE, -- It can be null because with people you generally don't have a due date.
    "fine" NUMERIC CHECK("fine" >= 0 AND "fine" = ROUND("fine", 2)) DEFAULT 0,
    "return_date" DATE,
    PRIMARY KEY("id"),
    FOREIGN KEY("lender_id") REFERENCES "people"("id"),
    FOREIGN KEY("library_id") REFERENCES "libraries"("id"),
    CHECK (
        ("entity_type" = 'person' AND "lender_id" IS NOT NULL AND "library_id" IS NULL)
        OR
        ("entity_type" = 'library' AND "library_id" IS NOT NULL AND "person_id" IS NULL AND "due_date" IS NOT NULL)
    )
);

CREATE TABLE "books_on_borrow" (
    "borrow_id" INTEGER,
    "book_id" INTEGER,
    FOREIGN KEY ("borrow_id") REFERENCES "borrows"("id"),
    FOREIGN KEY ("book_id") REFERENCES "books"("id"),
    PRIMARY KEY ("borrow_id", "book_id")
);


"""
    BOOKS }|--|| AUTHORS : writed
    BOOKS }|--o| TRANSLATORS : translated
    BOOKS }|--|| PUBLISHERS : had
    BOOKS ||--o| RATINGS : have
    BOOKS }|--o{ LENDS : lent
    BOOKS }|--o{ BORROWS : borrowed
    LENDS }o--|| PEOPLE : by
    BORROWS }o--o| PEOPLE : from
    BORROWS }o--o| LIBRARIES : from
    PEOPLE }o--o| ADDRESSES : resided
    LIBRARIES |o--|| ADDRESSES : located
    BOOKS }|--o{ TRANSACTIONS : have
    TRANSACTIONS }|--o| STORES : with
    TRANSACTIONS }o--o| PEOPLE : with
    STORES |o--o| ADDRESSES : located

    books nao precisa de ratings, loans, borrows, transactions
    people nao precisa de loans, borrows, transactions
    people nao precisa de address, address can be null
    stores nao precisa de address, address can be null
    transactions nao precisa de stores, people: only one should be null - transacao pode ser com pessoas ou com uma loja
    borrows nao precisa de libraries, people: only one can be null - emprestimos podem ser feitos com pessoas com uma biblioteca
    address nao precisa de stores, libraries, people: two should be null - endereço pode ser de uma loja, ou de uma biblioteca, ou de uma pessoa

"""

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
WHERE "location" = 'shelf' OR "location" = 'kindle'
ORDER BY "location";

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
WHERE "location" = 'shelf';

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
WHERE "location" = 'kindle';

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
WHERE "is_read" = TRUE;

-- To view all books that were borrowed
CREATE VIEW "borrowed_books" AS
SELECT "title", "year", "language" , "rating",
        (SELECT "first_name" || ' ' || "last_name"
         FROM "authors"
         JOIN "authored" ON "authored"."author_id" = "author"."id"
         WHERE "authored"."book_id" = "books"."id"
         ORDER BY "authors"."last_name" LIMIT 1) AS "author",
FROM "books"
JOIN "ratings" ON "ratings"."book_id" = "books"."id"
WHERE "borrowed" = TRUE;

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
WHERE "lent" = TRUE;

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
WHERE "sold" = TRUE;