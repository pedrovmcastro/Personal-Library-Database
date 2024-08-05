# Design Document

By Pedro de Castro

Video overview: <URL HERE>

## Scope

The purpose of this database is to allow the user to manage a personal library in a simple and effective manner. Includes all the necessary entities to help the user manage their books, loans, and transactions. The database's scope is:

* Books, including a wide range of information about them
* Authors, including basic identifying information
* Translators, including basic identifying information
* Publishers, including basic identifying information
* Book loans, including the type of loan (lend or borrow), the name of people involved, the time at which the loan was made, when the book was returned, as well as fines in case of delay
* Book transactions, including the type of transaction (purchase or sale), the name of people involved, the values, and the time at which the transaction was made

Out of scope are elements like personal information of the people involved, libraries and bookstores.

## Functional Requirements

This database will support:

* CRUD operations for books, authors, translators, publishers, loans and transactions
* Tracking the loans, including when and to whom each book was lent, when and from whom each book was borrowed, and allowing for a single loan with multiple books and with the possibility of having different due dates
* Triggers that automatically update the status of books when they go through a transaction or loan
* Soft deletion: maintains a history of all books that have been sold and borrowed

Beyond the scope is the fact that the total fine amount in case of delay is not updated automatically but needs to be updated manually

## Representation

### Entities

In this section you should answer the following questions:

* Which entities will you choose to represent in your database?
* What attributes will those entities have?
* Why did you choose the types you did?
* Why did you choose the constraints you did?

### Relationships

In this section you should include your entity relationship diagram and describe the relationships between the entities in your database.

![ER Diagram](diagram.png)

## Optimizations

In this section you should answer the following questions:

* Which optimizations (e.g., indexes, views) did you create? Why?

## Limitations

In this section you should answer the following questions:

* What are the limitations of your design?
* What might your database not be able to represent very well?