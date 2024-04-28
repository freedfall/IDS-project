------------------ DROP TABLES ------------------
DROP TABLE  Stuff        CASCADE CONSTRAINTS ;
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
-- base table for generalization, storing common attributes of all staff types
CREATE TABLE Stuff(
    StuffID       INT DEFAULT stuff_seq.NEXTVAL,
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
-- Similar to Receptionist, it extends Stuff, allowing for specialization of the staff INTo different roles.
CREATE TABLE Hotel_worker(
    StuffID         INT PRIMARY KEY,
    Type_of_service VARCHAR(255) NOT NULL,
    FOREIGN KEY (StuffID) REFERENCES Stuff(StuffID)
);
-- Rooms
CREATE TABLE Room(
    "Number"     INT PRIMARY KEY,
    Type         VARCHAR(255) NOT NULL,
    Availability number(1) NOT NULL
);
-- Guests
CREATE TABLE Guest(
    GuestID          INT DEFAULT guest_seq.NEXTVAL,
    Name             VARCHAR(255) NOT NULL,
    Surname          VARCHAR(255) NOT NULL,
    Telephone_number VARCHAR(20)  NOT NULL CHECK (regexp_like(Telephone_number, '^(\+[0-9]{12})|([0-9]{9})$')),
    Email            VARCHAR(50)  NOT NULL CHECK (regexp_like(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
    Total_spent INT DEFAULT 0,
    Loyalty_points INT DEFAULT 0,
    PRIMARY KEY (GuestID)
);
-- Reservation
CREATE TABLE Reservation(
    ReservationID  INT DEFAULT reservation_seq.NEXTVAL,
    DATEs          DATE NOT NULL,
    NumberOfGuests INT NOT NULL CHECK (NumberOfGuests > 0),
    GuestID        INT NOT NULL,
    RoomID         INT NOT NULL,
    StuffID        INT NOT NULL,
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (RoomID) REFERENCES Room("Number"),
    FOREIGN KEY (StuffID) REFERENCES Receptionist(StuffID),
    PRIMARY KEY (ReservationID)
);
-- Stay
CREATE TABLE Stay(
    StayID     INT DEFAULT stay_seq.NEXTVAL,
    Start_date DATE NOT NULL,
    End_date   DATE NOT NULL,
    Price      DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    CONSTRAINT check_date check (End_date > Start_date),
    GuestID    INT NOT NULL,
    ReservationID INT NOT NULL,
    PRIMARY KEY (StayID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);
-- Services
CREATE TABLE Services(
    ServiceID INT DEFAULT services_seq.NEXTVAL,
    Price     DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Type      VARCHAR(255) NOT NULL,
    DATE_time TIMESTAMP,
    StayID    INT NOT NULL,
    StuffID   INT NOT NULL,
    PRIMARY KEY (ServiceID),
    FOREIGN KEY (StayID) REFERENCES Stay(StayID),
    FOREIGN KEY (StuffID) REFERENCES Hotel_worker(StuffID)
);

------------------ insertions ------------------
-- Stuff
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (1, 'John', 'Doe', TO_DATE('1980-01-01', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (2, 'Jane', 'Smith', TO_DATE('1985-02-02', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (3, 'Dominique', 'Stefan', TO_DATE('2002-02-02', 'YYYY-MM-DD'));
INSERT INTO Stuff (StuffID, Name, Surname, DATE_of_birth) VALUES (4, 'Jaroslav', 'Stefan', TO_DATE('1999-10-15', 'YYYY-MM-DD'));

-- StuffID starts with 1, so we just add VALUES
INSERT INTO Receptionist (StuffID)                  VALUES (1);
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (2, 'Chef');
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (3, 'Security officer');
INSERT INTO Hotel_worker (StuffID, Type_of_service) VALUES (4, 'Room Service');

-- Rooms
INSERT INTO Room ("Number", Type, Availability) VALUES (101, 'Single', 1);
INSERT INTO Room ("Number", Type, Availability) VALUES (102, 'Double', 0);
INSERT INTO Room ("Number", Type, Availability) VALUES (103, 'Family', 0);
INSERT INTO Room ("Number", Type, Availability) VALUES (201, 'Family Lux', 1);

-- Guest
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (1, 'Alice', 'Brown', '+420721984672', 'alice_1010@gmail.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (2, 'Bob', 'Johnson', '+77475177182', 'bob.johnson@example.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (3, 'Karl', 'Mad', '987654321', 'karlM@proton.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (4, 'Emily', 'Patrick', '721974672', 'emPat@vutbr.cz');

-- Reservation
INSERT INTO Reservation (DATES, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (TO_DATE('2024-04-20', 'YYYY-MM-DD'), 1, 1, 101, 1);
INSERT INTO Reservation (DATES, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (TO_DATE('2024-04-22', 'YYYY-MM-DD'), 2, 2, 102, 1);
INSERT INTO Reservation (DATES, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (TO_DATE('2024-05-01', 'YYYY-MM-DD'), 3, 3, 103, 1);
INSERT INTO Reservation (DATES, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (TO_DATE('2024-05-25', 'YYYY-MM-DD'), 1, 4, 201, 1);

-- Stay
INSERT INTO Stay (Start_date, End_date, Price, GuestID, ReservationID) VALUES (TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-22', 'YYYY-MM-DD'), 100.00, 1, 1);
INSERT INTO Stay (Start_date, End_date, Price, GuestID, ReservationID) VALUES (TO_DATE('2024-04-22', 'YYYY-MM-DD'), TO_DATE('2024-05-01', 'YYYY-MM-DD'), 200.00, 2, 2);
INSERT INTO Stay (Start_date, End_date, Price, GuestID, ReservationID) VALUES (TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-25', 'YYYY-MM-DD'), 400.00, 3, 3);
INSERT INTO Stay (Start_date, End_date, Price, GuestID, ReservationID) VALUES (TO_DATE('2024-05-25', 'YYYY-MM-DD'), TO_DATE('2024-05-26', 'YYYY-MM-DD'), 110.00, 4, 4);

-- Services
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (50.00, 'Restaurant', TO_TIMESTAMP('2024-04-21 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 2);
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (25.00, 'Laundry', TO_TIMESTAMP('2024-04-22 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 3);
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (30.00, 'Minibar', TO_TIMESTAMP('2024-04-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 4);
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (50.00, 'Restaurant', TO_TIMESTAMP('2024-05-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 2);
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (25.00, 'Laundry', TO_TIMESTAMP('2024-05-03 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3);

------------------ SELECT ------------------

-- Select all guests and their stays
SELECT c.name, r.DATES, r.NumberOfGuests
FROM Guest c
JOIN Reservation r ON c.GuestID = r.GuestID;

-- Select all stays and their services
SELECT st.StayID, s.price, s.type, s.date_time
FROM Stay st
JOIN Services s ON s.StayID = st.StayID;

-- Select the guest related to stay and services provided
SELECT st.StayID, g.Name, g.Surname, g.Email, s.price, s.type, s.date_time
FROM Stay st
JOIN GUEST g on st.GuestID = g.GUESTID
JOIN SERVICES s on st.StayID = s.STAYID;

-- Select stay and group by price
SELECT s.Price, SUM(s.Price) as total_price
FROM Stay s
GROUP BY s.Price;

-- Select average price of service and group by it type
SELECT s.Type, AVG(s.Price) as avg_price
FROM Services s
GROUP BY s.Type;

-- Select guest who made a reservation for Family lux
SELECT g.name
FROM Guest g
WHERE EXISTS(
    SELECT 1
    FROM Reservation r
    WHERE RoomID = (SELECT rm."Number"
           FROM Room rm
           WHERE rm.Type = 'Family Lux'
    )
);

-- Select all Stays where Guests ordered a restaurant as service
SELECT s.*
FROM Stay s
WHERE s.StayID IN (
    SELECT sr.StayID
    FROM Services sr
    WHERE sr.Type = 'Restaurant'
);

------        ------
------ PART 4 ------
------        ------

-- Trigger to set room as unavailable when a reservation is made
CREATE OR REPLACE TRIGGER trg_room_book
AFTER INSERT ON Reservation
FOR EACH ROW
BEGIN
    UPDATE Room SET Availability = 0 WHERE "Number" = :NEW.RoomID;
END;
/

-- Trigger to set room as available and process checkout when a reservation is completed
CREATE OR REPLACE TRIGGER trg_room_release
AFTER UPDATE OF End_date ON Stay
FOR EACH ROW
WHEN (NEW.End_date <= SYSDATE)
BEGIN
    UPDATE Room
    SET Availability = 1
    WHERE "Number" = (
        SELECT RoomID
        FROM Reservation
        WHERE ReservationID = :NEW.ReservationID
    );

     -- Call the Process_Checkout procedure
    Process_Checkout(:NEW.StayID);

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle exceptions by outputting error message
            DBMS_OUTPUT.put_line('Error during checkout: ' || SQLERRM);
END;
/

-- Trigger to update guest's loyalty points after checkout
CREATE OR REPLACE TRIGGER trg_update_loyalty_points
FOR UPDATE OF End_date ON Stay
COMPOUND TRIGGER

    -- Collection to hold necessary data for stays and their service costs
    TYPE StayRec IS RECORD (
        StayID Stay.StayID%TYPE,
        GuestID Guest.GuestID%TYPE,
        TotalCost NUMBER
    );
    TYPE StayTab IS TABLE OF StayRec INDEX BY PLS_INTEGER;
    v_stays StayTab;

    -- After each row, collect data
    AFTER EACH ROW IS
        v_service_cost NUMBER;
    BEGIN
        -- Initialize the total cost with the stay's cost
        v_service_cost := 0;

        -- Calculate total service costs for the stay
        SELECT SUM(Price) INTO v_service_cost
        FROM Services
        WHERE StayID = :NEW.StayID;

        -- If no services were added, ensure the sum is not null
        IF v_service_cost IS NULL THEN
            v_service_cost := 0;
        END IF;

        -- Store in collection
        v_stays(v_stays.COUNT + 1).StayID := :NEW.StayID;
        v_stays(v_stays.COUNT).GuestID := :NEW.GuestID;
        v_stays(v_stays.COUNT).TotalCost := :NEW.Price + v_service_cost;
    END AFTER EACH ROW;

    -- After statement, process all collected data
    AFTER STATEMENT IS
        v_loyalty_points INT;
    BEGIN
        FOR i IN 1 .. v_stays.COUNT LOOP
            -- Calculate loyalty points (1 point per $10 spent)
            v_loyalty_points := v_stays(i).TotalCost / 10;

            -- Update the Guest record with new totals and loyalty points
            UPDATE Guest
            SET Total_spent = Total_spent + v_stays(i).TotalCost,
                Loyalty_points = Loyalty_points + v_loyalty_points
            WHERE GuestID = v_stays(i).GuestID;
        END LOOP;
    END AFTER STATEMENT;

END trg_update_loyalty_points;
/

-- Procedure to calculate total bill for a stay and apply discount if applicable
CREATE OR REPLACE PROCEDURE Process_Checkout(p_stay_id IN Stay.StayID%TYPE)
IS
    v_total_bill DECIMAL(10,2) := 0;
    v_price      DECIMAL(10,2);
    v_discount   DECIMAL(10,2) := 0.1; -- Example discount of 10%
    cursor c_services IS
        SELECT Price FROM Services WHERE StayID = p_stay_id;
BEGIN
    -- Calculate total cost from Stay
    SELECT Price INTO v_price FROM Stay WHERE StayID = p_stay_id;
    v_total_bill := v_price;

    -- Calculate total cost from Services
    FOR rec IN c_services LOOP
        v_total_bill := v_total_bill + rec.Price;
    END LOOP;

    -- Apply discount if applicable
    IF v_total_bill > 500 THEN
        v_total_bill := v_total_bill - (v_total_bill * v_discount);
    END IF;

    -- Update the Stay record with the total bill
    UPDATE Stay SET Price = v_total_bill WHERE StayID = p_stay_id;

    -- Handle exceptions for missing data
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.put_line('Error: No data found for Stay ID: ' || p_stay_id);
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('An unexpected error occurred: ' || SQLERRM);
END;
/

-- Procedure to calculate occupancy rate for every room in given period
CREATE OR REPLACE PROCEDURE Calculate_Occupancy_Rate(
    p_start_date IN DATE,
    p_end_date IN DATE)
IS
    v_room_type VARCHAR2(255);
    v_occupied_days NUMBER;
    v_possible_days NUMBER;
    v_occupancy_rate NUMBER;
    CURSOR room_types IS
        SELECT DISTINCT Type FROM Room;
BEGIN
    -- Loop through each room type to calculate occupancy rates
    FOR r IN room_types LOOP
        v_room_type := r.Type;

        -- Calculate the number of days each room type was actually occupied
        SELECT SUM((LEAST(s.End_date, p_end_date) - GREATEST(s.Start_date, p_start_date)) + 1)
        INTO v_occupied_days
        FROM Stay s JOIN Room rm ON (SELECT RoomID FROM Reservation WHERE ReservationID = s.ReservationID) = rm."Number"
        WHERE rm.Type = v_room_type
        AND s.Start_date <= p_end_date
        AND s.End_date >= p_start_date;

        -- Calculate the total possible occupancy days for the room type
        SELECT COUNT(*) * (p_end_date - p_start_date + 1)
        INTO v_possible_days
        FROM Room
        WHERE Type = v_room_type;

        -- Calculate the occupancy rate
        IF v_possible_days > 0 THEN
            v_occupancy_rate := (v_occupied_days / v_possible_days) * 100;
        ELSE
            v_occupancy_rate := 0;
        END IF;

        -- Output the results
        DBMS_OUTPUT.put_line('Room Type: ' || v_room_type || ' Occupancy Rate: ' || TO_CHAR(v_occupancy_rate, 'FM999990.00') || '%');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error calculating occupancy rates: ' || SQLERRM);
END;
/

----- Test the Process_Checkout procedure -----
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (101, 'Test', 'User', '+123456789', 'test@test.com');
INSERT INTO Room ("Number", Type, Availability) VALUES (1337, 'Single', 1);
INSERT INTO Reservation (ReservationID, DATES, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (101, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 1, 101, 1337, 1);
INSERT INTO Stay (StayID, Start_date, End_date, Price, GuestID, ReservationID) VALUES (101, TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-22', 'YYYY-MM-DD'), 100.00, 101, 101);
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID) VALUES (50.00, 'Restaurant', TO_TIMESTAMP('2024-04-21 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 101, 2);

-- Select Stay with initial price = 100
SELECT * FROM Stay WHERE StayID = 101;

-- Call the Process_Checkout procedure
BEGIN
    Process_Checkout(101);
END;

-- Select Stay with new price
SELECT * FROM Stay WHERE StayID = 101;

DELETE Services WHERE StayID = 101;
DELETE Stay WHERE StayID = 101;
DELETE Reservation WHERE ReservationID = 101;
DELETE Guest WHERE GuestID = 101;
DELETE Room WHERE "Number" = 1337;

----- Tests for Calculate_Occupancy_Rate procedure -----
-- Insert Rooms of different types
INSERT INTO Room ("Number", Type, Availability) VALUES (101, 'Single', 1);
INSERT INTO Room ("Number", Type, Availability) VALUES (102, 'Double', 1);
INSERT INTO Room ("Number", Type, Availability) VALUES (103, 'Suite', 1);

-- Insert Guests
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (101, 'Alice', 'Wonderland', '+1234567890', 'alice@example.com');
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email) VALUES (202, 'Bob', 'Builder', '+0987654321', 'bob@example.com');

-- Insert Reservations and Stays
INSERT INTO Reservation (ReservationID, DATEs, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (101, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 1, 101, 101, 1);
INSERT INTO Reservation (ReservationID, DATEs, NumberOfGuests, GuestID, RoomID, StuffID) VALUES (202, TO_DATE('2024-05-01', 'YYYY-MM-DD') - 20, 202, 2, 102, 1);
INSERT INTO Stay (StayID, Start_date, End_date, Price, GuestID, ReservationID) VALUES (101, TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-25', 'YYYY-MM-DD'), 500, 101, 101);
INSERT INTO Stay (StayID, Start_date, End_date, Price, GuestID, ReservationID) VALUES (202, TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-10', 'YYYY-MM-DD'), 1000, 202, 202);

-- Test 1: Basic Functionality
BEGIN
   -- Dates that cover full period
   Calculate_Occupancy_Rate(TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-05-30', 'YYYY-MM-DD'));
END;
/

-- Test 2: Single room full occupancy test
BEGIN
   Calculate_Occupancy_Rate(TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2024-04-25', 'YYYY-MM-DD'));
END;
/

-- Test 3: Zero Occupancy Test
BEGIN
   Calculate_Occupancy_Rate(TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-31', 'YYYY-MM-DD'));
END;
/

DELETE Services WHERE StayID = 101 OR StayID = 202;
DELETE Stay WHERE StayID = 101 OR StayID = 202;
DELETE Reservation WHERE ReservationID = 101 OR ReservationID = 202;
DELETE Guest WHERE GuestID = 101 OR GuestID = 202;

----- Tests for loyalty points trigger -----
-- Insert Room
INSERT INTO Room ("Number", Type, Availability)
VALUES (101, 'Single', 1);

-- Insert Guest
INSERT INTO Guest (GuestID, Name, Surname, Telephone_number, Email, Total_spent, Loyalty_points)
VALUES (42, 'John', 'Doe', '+1234567890', 'john.doe@example.com', 0, 0);

-- Insert reservation
INSERT INTO Reservation(RESERVATIONID, DATES, NUMBEROFGUESTS, GUESTID, ROOMID, STUFFID)
VALUES (42, DATE '2024-01-20', 1, 42, 101, 1);

-- Insert Stay
INSERT INTO Stay (StayID, ReservationID, GuestID, Start_date, End_date, Price)
VALUES (42, 42, 42, DATE '2024-04-20', DATE '2024-04-23', 1000);

-- Insert Services
INSERT INTO Services (Price, Type, DATE_time, StayID, StuffID)
VALUES (300, 'Spa', TO_TIMESTAMP('2024-04-21 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 42, 2);

SELECT Total_spent, Loyalty_points FROM Guest WHERE GuestID = 42;

-- Trigger the checkout process
UPDATE Stay SET End_date = SYSDATE-1 WHERE StayID = 42;

-- Check results
SELECT Total_spent, Loyalty_points FROM Guest WHERE GuestID = 42;

-- Add another service
INSERT INTO Services (ServiceID, StayID, Type, Price, DATE_time, STUFFID)
VALUES (2, 42, 'Massage', 200, SYSTIMESTAMP, 2);

-- Update Stay to re-trigger
UPDATE Stay SET End_date = SYSDATE WHERE StayID = 42;

-- Check results
SELECT Total_spent, Loyalty_points FROM Guest WHERE GuestID = 42;

DELETE Services WHERE StayID = 42;
DELETE Stay WHERE StayID = 42;
DELETE Reservation WHERE ReservationID = 42;
DELETE Guest WHERE GuestID = 42;

------                          ------
------ INDEXES AND EXPLAIN PLAN ------
------                          ------

-- Creating index on the End date column of the Stay table to optimize queries looking for stays that are about to end or have recently ended
CREATE INDEX idx_stay_end_date ON Stay(End_date);

-- Delete index
DROP INDEX idx_stay_end_date;

-- Run EXPLAIN PLAN before and after creating the index
EXPLAIN PLAN FOR SELECT * FROM Stay WHERE End_date BETWEEN SYSDATE AND SYSDATE + 3;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Explain plan for finding total revenue of every room type over the year
EXPLAIN PLAN FOR
SELECT Type, SUM(s.Price + NVL(serv.total_service_cost, 0)) AS Total_Revenue FROM Room r
JOIN Stay s ON r."Number" = (SELECT RoomID FROM RESERVATION WHERE ReservationID = s.ReservationID)
LEFT JOIN (
    SELECT StayID, SUM(Price) AS total_service_cost
    FROM Services
    GROUP BY StayID
) serv ON s.StayID = serv.StayID
WHERE s.Start_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'
GROUP BY r.Type;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Create index on stayID in services to optimize query
CREATE INDEX idx_services_stayID ON Services(StayID);
DROP INDEX idx_services_stayID;

-- Granting access for second team member
GRANT SELECT, INSERT, UPDATE, DELETE ON Room TO xpodho08;
GRANT SELECT, INSERT, UPDATE, DELETE ON Stuff TO xpodho08;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservation TO xpodho08;
GRANT SELECT, INSERT, UPDATE, DELETE ON Stay TO xpodho08;
GRANT SELECT, INSERT, UPDATE, DELETE ON Guest TO xpodho08;
GRANT SELECT, INSERT, UPDATE, DELETE ON Services TO xpodho08;

GRANT CREATE TABLE TO xpodho08;
GRANT ALTER TO xpodho08;
GRANT DROP ANY TABLE TO xpodho08;

CREATE MATERIALIZED VIEW room_reservation_summary AS
SELECT r.Type, COUNT(*) AS total_reservations
FROM Room r
JOIN Reservation res ON r."Number" = res.RoomID
GROUP BY r.Type;

-- Complex SELECT query to analyze spending behavior of guests based on their total spent
-- Data retrieved by the query:
    -- Guest name and email
    -- Total spent
    -- Spending category
-- WITH aggregates the total amount spent my each guest
WITH GuestSpending AS (
    SELECT
        g.GuestID,
        g.Name,
        g.Email,
        SUM(s.Price + COALESCE(serv.Price, 0)) AS TotalSpent
    FROM Guest g
    JOIN Stay s ON g.GuestID = s.GuestID
    LEFT JOIN (
        SELECT StayID, SUM(Price) AS Price
        FROM Services
        GROUP BY StayID
    ) serv ON s.StayID = serv.StayID
    GROUP BY g.GuestID, g.Name, g.Email
)
SELECT -- main select statement
    Name,
    Email,
    TotalSpent,
    CASE -- categorizes each guest
        WHEN TotalSpent > 1000 THEN 'High Spender'
        WHEN TotalSpent BETWEEN 500 AND 1000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS SpendingCategory
FROM GuestSpending;