CREATE VIEW "lent_books2" AS
SELECT 
    b."title", 
    b."year", 
    (
        SELECT a."first_name" || ' ' || a."last_name"
        FROM "authors" a
        JOIN "authored" au ON au."author_id" = a."id"
        WHERE au."book_id" = b."id"
        ORDER BY a."last_name" 
        LIMIT 1
    ) AS "author",
    b."language", 
    r."rating",
    (
        SELECT p."name"
        FROM "people" p
        JOIN "lends" l ON l."borrower_id" = p."id"
        JOIN "books_on_lend" bl ON bl."lend_id" = l."id"
        WHERE bl."book_id" = b."id"
        ORDER BY l."lend_date"
        LIMIT 1
        
    ) AS "borrower"        
FROM "books" b
JOIN "ratings" r ON r."book_id" = b."id"
WHERE "lent" = TRUE;