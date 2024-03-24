------------------ DROP TABLES ------------------
DROP TABLE  Stuff        CASCADE CONSTRAINTS;
DROP TABLE  Receptionist CASCADE CONSTRAINTS;
DROP TABLE  Hotel_worker CASCADE CONSTRAINTS;
DROP TABLE  Room         CASCADE CONSTRAINTS;
DROP TABLE  Reservation  CASCADE CONSTRAINTS;
DROP TABLE  Guest        CASCADE CONSTRAINTS;
DROP TABLE  Stay         CASCADE CONSTRAINTS;
DROP TABLE  Services     CASCADE CONSTRAINTS;

------------------ DROP SEQUENCES ------------------
DROP SEQUENCE stuff_seq;
DROP SEQUENCE guest_seq;
DROP SEQUENCE reservation_seq;
DROP SEQUENCE services_seq;
DROP SEQUENCE stay_seq;

------------------ CREATE SEQUENCES ------------------
CREATE SEQUENCE stuff_seq       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE guest_seq       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE reservation_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE services_seq    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE stay_seq        START WITH 1 INCREMENT BY 1;

------------------ CREATE TABLES ------------------
-- Base table for generalization, storing common attributes of all staff types
CREATE TABLE Stuff(
    StuffID       INT DEFAULT stuff_seq.NEXTVAL NOT NULL,
    Name          VARCHAR(255) NOT NULL,
    Surname       VARCHAR(255) NOT NULL,
    DATE_of_birth DATE NOT NULL,
    PRIMARY KEY (StuffID)
);
-- Receptionist table, inheriting common attributes from Stuff via foreign key.
-- This approach represents a "one table per subclass" inheritance model,
-- where each subclass table contains a PRIMARY KEY that also acts as a foreign key referencing the base class.
CREATE TABLE Receptionist(
    StuffID INT PRIMARY KEY,
    FOREIGN KEY (StuffID) REFERENCES Stuff(StuffID)
);
-- Hotel worker table with specific attribute "Type_of_service".
-- Similar to Receptionist, it extends Stuff, allowing for specialization of the staff into different roles.
CREATE TABLE Hotel_worker(
    StuffID         INT PRIMARY KEY NOT NULL,
    Type_of_service VARCHAR(255) NOT NULL,
    FOREIGN KEY (StuffID) REFERENCES Stuff(StuffID)
);
-- Rooms
CREATE TABLE Room(
    "Number"     INT PRIMARY KEY NOT NULL,
    Type         VARCHAR(255) NOT NULL,
    Availability number(1) NOT NULL
);
-- Reservation
CREATE TABLE Reservation(
    ReservationID  INT DEFAULT reservation_seq.NEXTVAL NOT NULL,
    DATEs          DATE NOT NULL,
    NumberOfGuests INT NOT NULL CHECK (NumberOfGuests > 0),
    PRIMARY KEY (ReservationID)
);
-- Guests
CREATE TABLE Guest(
    GuestID          INT DEFAULT guest_seq.NEXTVAL NOT NULL,
    Name             VARCHAR(255) NOT NULL,
    Surname          VARCHAR(255) NOT NULL,
    Telephone_number VARCHAR(20)  NOT NULL CHECK (regexp_like(Telephone_number, '^(\+[0-9]{12})|([0-9]{9})$')),
    Email            VARCHAR(50)  NOT NULL CHECK (regexp_like(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
    PRIMARY KEY (GuestID)
);
-- Stay
CREATE TABLE Stay(
    StayID     INT DEFAULT stay_seq.NEXTVAL NOT NULL,
    Start_date DATE NOT NULL,
    End_date   DATE NOT NULL,
    Price      DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    CONSTRAINT check_date CHECK (End_date > Start_date),
    PRIMARY KEY (StayID)
);
-- Services
CREATE TABLE Services(
    ServiceID INT DEFAULT services_seq.NEXTVAL NOT NULL,
    Price     DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Type      VARCHAR(255) NOT NULL,
    DATE_time TIMESTAMP,
    PRIMARY KEY (ServiceID)
);

------------------ INSERTIONS ------------------
-- Stuff
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (1, 'John', 'Doe', TO_DATE('1980-01-01', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (2, 'Jane', 'Smith', TO_DATE('1985-02-02', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (3, 'Dominique', 'Stefan', TO_DATE('2002-02-02', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (4, 'Jaroslav', 'Stefan', TO_DATE('1999-10-15', 'YYYY-MM-DD'));

-- Make one worker a receptionist, others are different stuff
INSERT INTO Receptionist (StuffID)                  VALUES (1);
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (2, 'Chef');
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (3, 'Security officer');
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (4, 'Room Service');

-- Rooms
INSERT INTO Room ("Number", Type, Availability) VALUES (101, 'Single', 1);
INSERT INTO Room ("Number", Type, Availability) VALUES (102, 'Double', 0);
INSERT INTO Room ("Number", Type, Availability) VALUES (103, 'Family', 0);
INSERT INTO Room ("Number", Type, Availability) VALUES (201, 'Family Lux', 1);

-- Reservation
INSERT INTO Reservation (DATES, NumberOfGuests) VALUES (TO_DATE('2024-04-20', 'YYYY-MM-DD'), 2);
INSERT INTO Reservation (DATES, NumberOfGuests) VALUES (TO_DATE('2024-04-22', 'YYYY-MM-DD'), 1);
INSERT INTO Reservation (DATES, NumberOfGuests) VALUES (TO_DATE('2024-05-25', 'YYYY-MM-DD'), 1);
INSERT INTO Reservation (DATES, NumberOfGuests) VALUES (TO_DATE('2024-05-01', 'YYYY-MM-DD'), 4);

-- Guest
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (1, 'Alice', 'Brown', '+420721984672', 'alice_1010@gmail.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (2, 'Bob', 'Johnson', '+77475177182', 'bob.johnson@example.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (3, 'Karl', 'Mad', '987654321', 'karlM@proton.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (4, 'Emily', 'Patrick', '721974672', 'emPat@vutbr.cz');

-- Stay
INSERT INTO Stay (Start_date, End_date, Price) VALUES (TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-23', 'YYYY-MM-DD'), 100.00);
INSERT INTO Stay (Start_date, End_date, Price) VALUES (TO_DATE('2024-04-22', 'YYYY-MM-DD'), TO_DATE('2024-04-25', 'YYYY-MM-DD'), 150.00);
INSERT INTO Stay (Start_date, End_date, Price) VALUES (TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-09', 'YYYY-MM-DD'), 400.00);
INSERT INTO Stay (Start_date, End_date, Price) VALUES (TO_DATE('2024-05-25', 'YYYY-MM-DD'), TO_DATE('2024-05-27', 'YYYY-MM-DD'), 110.00);

-- Services
INSERT INTO Services (Price, Type, DATE_time) VALUES (50.00, 'Breakfast', TO_TIMESTAMP('2024-04-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Services (Price, Type, DATE_time) VALUES (75.00, 'Spa', TO_TIMESTAMP('2024-04-21 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Services (Price, Type, DATE_time) VALUES (25.00, 'Laundry', TO_TIMESTAMP('2024-04-22 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Services (Price, Type, DATE_time) VALUES (30.00, 'Minibar', TO_TIMESTAMP('2024-04-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Services (Price, Type, DATE_time) VALUES (100.00, 'Airport transfer', TO_TIMESTAMP('2024-04-23 09:00:00', 'YYYY-MM-DD HH24:MI:SS'));
