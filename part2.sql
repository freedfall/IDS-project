-- drop tables
drop table  Stuff cascade constraints ;
drop table  Receptionist cascade constraints;
drop table  Hotel_worker cascade constraints;
drop table  Room cascade constraints;
drop table  Reservation cascade constraints;
drop table  Guest cascade constraints;
drop table  Stay cascade constraints;
drop table  Services cascade constraints;

-- drop sequences
drop sequence stuff_seq;
drop sequence guest_seq;
drop sequence reservation_seq;
drop sequence services_seq;
drop sequence stay_seq;

-- sequences
create sequence stuff_seq start with 1 increment by 1;
create sequence guest_seq start with 1 increment by 1;
create sequence reservation_seq start with 1 increment by 1;
create sequence services_seq start with 1 increment by 1;
create sequence stay_seq start with 1 increment by 1;

-- create tables
-- base table for generalization, storing common attributes of all staff types
create table Stuff(
    StuffID int default stuff_seq.nextval,
    Name varchar(255) not null,
    Surname varchar(255) not null,
    Date_of_birth date not null,
    primary key (StuffID)
);
-- Receptionist table, inheriting common attributes from Stuff via foreign key.
-- This approach represents a "one table per subclass" inheritance model,
-- where each subclass table contains a primary key that also acts as a foreign key referencing the base class.
create table Receptionist(
    StuffID int primary key,
    FOREIGN KEY (StuffID) REFERENCES Stuff(StuffID)
);
-- Hotel worker table with specific attribute "Type_of_service".
-- Similar to Receptionist, it extends Stuff, allowing for specialization of the staff into different roles.
create table Hotel_worker(
    StuffID int primary key,
    Type_of_service varchar(255) not null,
    FOREIGN KEY (StuffID) REFERENCES Stuff(StuffID)
);
-- Rooms
create table Room(
    "Number" int primary key,
    Type varchar(255) not null,
    Availability number(1) not null
);
-- Reservation
create table Reservation(
    ReservationID int primary key,
    Dates date not null,
    NumberOfGuests int not null
);
-- Guests
create table Guest(
    GuestID          int default guest_seq.nextval,
    Name             varchar(255) not null,
    Surname          varchar(255) not null,
    Telephone_number varchar(20) not null check (regexp_like(Telephone_number, '^(\+[0-9]{12})|([0-9]{9})$')),
    Email            varchar(50) not null check (regexp_like(Email, '^[a-z0-9.-_]+@[a-z0-9.-_]+]\.[a-z]+]$')),
    primary key (GuestID)
    --check if number is either in international format (+ and 12 chars) or in local (9 digits)
--     constraint telephone_number_check check (Telephone_number like '+___________' or Telephone_number like '_________'),
    --check that there is an '@' character in the string and a dot after it
--     constraint email_check check (INSTR(Email, '@') > 1 AND INSTR(Email, '.', -1, 1) > INSTR(Email, '@'))
);
-- Stay
create table Stay(
    StayID int primary key,
    Start_date date not null,
    End_date date not null,
    Price decimal(10,2) not null
);
-- Services
create table Services(
    ServiceID int primary key,
    Price decimal(10,2) not null,
    Type varchar(255) not null,
    Date_time timestamp
);

-- using sequences to autofill keys
alter table Stuff       modify (StuffID int DEFAULT stuff_seq.NEXTVAL);
alter table Guest       modify (GuestID int DEFAULT guest_seq.NEXTVAL);
alter table Reservation modify (ReservationID int DEFAULT reservation_seq.NEXTVAL);
alter table Services    modify (ServiceID int DEFAULT services_seq.NEXTVAL);
alter table Stay        modify (StayID int DEFAULT stay_seq.NEXTVAL);

-- insertions
-- Stuff
insert into Stuff (StuffID, Name, Surname, Date_of_birth) values (1, 'John', 'Doe', TO_DATE('1980-01-01', 'YYYY-MM-DD'));
insert into Stuff (StuffID, Name, Surname, Date_of_birth) values (2, 'Jane', 'Smith', TO_DATE('1985-02-02', 'YYYY-MM-DD'));
insert into Stuff (StuffID, Name, Surname, Date_of_birth) values (3, 'Clown', 'Kalovich', TO_DATE('2002-02-02', 'YYYY-MM-DD'));

-- StuffID starts with 1, so we just add values
insert into Receptionist (StuffID) values (1);
insert into Hotel_worker (StuffID, Type_of_service) values (2, 'Room Service');

-- Rooms
insert into Room ("Number", Type, Availability) values (101, 'Single', true);
insert into Room ("Number", Type, Availability) values (102, 'Double', false);

-- Reservation
insert into Reservation (Dates, NumberOfGuests) values (TO_DATE('2024-04-20', 'YYYY-MM-DD'), 2);
insert into Reservation (Dates, NumberOfGuests) values (TO_DATE('2024-04-22', 'YYYY-MM-DD'), 1);

-- Guest
insert into Guest (GuestID, Name, Surname, Telephone_number, Email) values (1, 'Alice', 'Brown', '+420721974672', 'alice.brown@example.com');
insert into Guest (GuestID, Name, Surname, Telephone_number, Email) values (2, 'Bob', 'Johnson', '987654321', 'bob.johnson@example.com');

-- Stay
insert into Stay (Start_date, End_date, Price) values (TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-23', 'YYYY-MM-DD'), 100.00);
insert into Stay (Start_date, End_date, Price) values (TO_DATE('2024-04-22', 'YYYY-MM-DD'), TO_DATE('2024-04-25', 'YYYY-MM-DD'), 150.00);

-- Services
insert into Services (Price, Type, Date_time) values (50.00, 'Breakfast', TO_TIMESTAMP('2024-04-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
insert into Services (Price, Type, Date_time) values (75.00, 'Spa', TO_TIMESTAMP('2024-04-21 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));