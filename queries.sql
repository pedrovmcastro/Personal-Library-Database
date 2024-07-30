-- Adding four books in the library:

INSERT INTO "authors" ("first_name", "last_name", "nationality", "date_of_birth")
VALUES
("José de", "Alencar", "brazilian", "1829-05-01"),
("Dyonelio", "Machado", "brazilian", "1895-08-21"),
("Graciliano", "Ramos", "brazilian", "1892-10-27" ),
("Lu", "Xun", "chinese", "1881-09-25");

INSERT INTO "translators" ("first_name", "last_name", "nationality", "date_of_birth")
VALUES
("Yu Pin", "Fang", "brazilian", NULL)

INSERT INTO "addresses" ("street", "city", "country", "postal-code")
VALUES
("Rua Argentina, 171", "Rio de Janeiro", "Brazil", "23.052") -- Editora Record
("Rua Barão de Igape, 110", "São Paulo", "Brazil", "8656") -- Editora Ática
("Rua Sérgio Buarque de Holanda, 421", "Campinas", "Brazil", "13083-859") -- Editora da Unicamp

INSERT INTO "publishers" ("name", "founded_year", "phone_number", "email", "website", "address_id")
VALUES
("Record", 1942, NULL, NULL, "record.com.br", 1)
("Ática", 1965, NULL, NULL, NULL, 2)
("Objetivo", NULL, NULL, NULL, NULL, NULL)
("Unicamp", 1982, NULL, NULL, "editoraunicamp.com.br", 3)

INSERT INTO "books" ("title", "language", "original_language", "bilingual_edition", "year", "edition", "edition_year", 
"category", "genre", "location", "translator_id", "publisher_id", "rating_id")
VALUES
("Iracema", "portuguese", "portuguese", FALSE, 1865, NULL, NULL, "brazilian literature", "novel", "shelf", NULL, 3, NULL)
("Angústia", "portuguese", "portuguese", FALSE, 1936, 38, 1992, "brazilian literature", "novel", "shelf", NULL, 1, NULL)
("Os Ratos", "portuguese", "portuguese", FALSE, 1935, 12, 1992, "brazilian literature", "novel", "shelf", NULL, 2, NULL)
("Flores matinais colhidas ao entardecer", "portuguese", "chinese", TRUE, 1926, 1, 2021, "chinese literature", "chronicle", "shelf", 1, 4, NULL)

INSERT INTO "authored" ("author_id", "book_id")
VALUES
(1, 1)
(2, 3)
(3, 2)
(4, 4)

-- Digamos que eu queira emprestar o "Os Ratos" e "Iracema" para um amigo chamado Fábio

INSERT INTO "addresses" ("street", "city", "country", "postal-code")
VALUES
("Avenida Anchieta, 890", "Campinas", "Brazil", "13025-047") -- Fabio's address

INSERT INTO "people" ("name", "phone_number", "email", "address_id")
VALUES
("Fábio", "99999-9999", "fabio@email.com", 4)

INSERT INTO "lends" ("borrower_id")
VALUES
(1) -- "Fabio's id"

INSERT INTO "books_on_lend" ("lend_id", "book_id")
VALUES
(1, 1)
(1, 2)



