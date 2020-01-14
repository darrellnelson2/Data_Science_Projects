/*
	Author : Darrell Nelson II
	Course : IST659 M402
	Term : Fall, 2018
	Final Project
	*/

/*
	Section: Physical Database Desgin

	Action: Building tables listed in Logical Model Diagram. Must drop then build tables 
	in a sequential order so no errors arise when we rerun this code in order to repopulate the tables.
	Order is as follows:
	Drop --> Check, Session, TutorSubject, SessionMeetingDay, Room, ClientTutor, ClientSubject, Tutor, Subject, & Client
	CREATE --> Client, Subject, Tutor, ClientSubject, ClientTutor, Room, SessionMeetingDay, TutorSubject, Session, & Check
*/

--Dropping Tables in Order Specified in the Physical Database Design comment header
IF OBJECT_ID('[Check]') IS NOT NULL
DROP TABLE [Check];
GO

IF OBJECT_ID('[Session]') IS NOT NULL
DROP TABLE [Session];
GO

IF OBJECT_ID('TutorSubject') IS NOT NULL
DROP TABLE TutorSubject;
GO

IF OBJECT_ID('SessionMeetingDay') IS NOT NULL
DROP TABLE SessionMeetingDay;
GO

IF OBJECT_ID('Room') IS NOT NULL
DROP TABLE Room;
GO

IF OBJECT_ID('ClientTutor') IS NOT NULL
DROP TABLE ClientTutor;
GO

IF OBJECT_ID('ClientSubject') IS NOT NULL
DROP TABLE ClientSubject;
GO

IF OBJECT_ID('Tutor') IS NOT NULL
DROP TABLE Tutor;
GO

IF OBJECT_ID('[Subject]') IS NOT NULL
DROP TABLE [Subject];
GO

IF OBJECT_ID('Client') IS NOT NULL
DROP TABLE Client;
GO

-- Creating tables in the specified Order given in the Physical Database Design comment header
	-- Create Client Table 
	CREATE TABLE Client (
		-- Columns for the Client table
		ClientID int identity,
		FirstName varchar(30) not null,
		MiddleInitial char(1),
		LastName varchar(30) not null,
		EmailAddress varchar(30) not null,
		-- Constraints on the Client Table
		CONSTRAINT PK_Client PRIMARY KEY (ClientID),
		CONSTRAINT U1_Client UNIQUE(EmailAddress)
)
--End Creating the Client table

	-- Create Subject Table 
	CREATE TABLE [Subject] (
		-- Columns for the Subject table
		SubjectID int identity,
		SubjectName varchar(20) not null,
		GradeLevel varchar(20) not null,
		-- Constraints on the Subject Table
		CONSTRAINT PK_Subject PRIMARY KEY (SubjectID)
)
--End Creating the Subject table

	-- Create Tutor Table 
	CREATE TABLE Tutor (
		-- Columns for the Tutor table
		TutorID int identity,
		FirstName varchar(30) not null,
		MiddleInitial char(1),
		LastName varchar(30) not null,
		EmailAddress varchar(30) not null,
		-- Constraints on the Tutor Table
		CONSTRAINT PK_Tutor PRIMARY KEY (TutorID),
		CONSTRAINT U1_Tutor UNIQUE(EmailAddress)
)
--End Creating the Tutor table

	-- Creating the ClientSubject table
	CREATE TABLE ClientSubject (
		-- Columns for the ClientSubject table
		ClientSubjectID int identity,
		ClientID int not null,
		SubjectID int not null,
		-- Constraints on the ClientSubject table
		CONSTRAINT PK_ClientSubject PRIMARY KEY (ClientSubjectID),
		CONSTRAINT FK1_ClientSubject FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
		CONSTRAINT FK2_ClientSubject FOREIGN KEY (SubjectID) REFERENCES [Subject](SubjectID)
)
-- End creating the ClientSubject table

	-- Creating the ClientTutor table
	CREATE TABLE ClientTutor (
		-- Columns for the ClientTutor table
		ClientTutorID int identity,
		ClientID int not null,
		TutorID int not null,
		-- Constraints on the ClientTutor table
		CONSTRAINT PK_ClientTutor PRIMARY KEY (ClientTutorID),
		CONSTRAINT FK1_ClientTutor FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
		CONSTRAINT FK2_ClientTutor FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID)
)
-- End creating the ClientTutor table

	-- Creating the Room table
	CREATE TABLE Room (
		-- Columns for the Room table
		RoomID int identity,
		RoomNumber varchar(10) not null,
		SubjectID int not null,
		-- Constraints on the Room table
		CONSTRAINT PK_Room PRIMARY KEY (RoomID),
		CONSTRAINT U1_Room UNIQUE (RoomNumber),
		CONSTRAINT FK1_Room FOREIGN KEY (SubjectID) REFERENCES [Subject](SubjectID),
)
-- End creating the Room table

	-- Creating the SessionMeetingDay table
	CREATE TABLE SessionMeetingDay (
		-- Columns for the SessionMeetingDay table
		SessionMeetingDayID int identity,
		[DayOfWeek] varchar(10) not null,
		-- Constraints on the SessionMeetingDay table
		CONSTRAINT PK_SessionMeetingDay PRIMARY KEY (SessionMeetingDayID),
		CONSTRAINT U1_SessionMeetingDay UNIQUE ([DayOfWeek]),
)
-- End creating the SessionMeetingDay table

	-- Creating the TutorSubject table
	CREATE TABLE TutorSubject (
		-- Columns for the TutorSubject table
		TutorSubjectID int identity,
		TutorRate money not null,
		TutorID int not null,
		SubjectID int not null,
		-- Constraints on the TutorSubject table
		CONSTRAINT PK_TutorSubject PRIMARY KEY (TutorSubjectID),
		CONSTRAINT FK1_TutorSubject FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
		CONSTRAINT FK2_TutorSubject FOREIGN KEY (SubjectID) REFERENCES [Subject](SubjectID)
)
-- End creating the TutorSubject table

	-- Creating the Session table
	CREATE TABLE [Session] (
		-- Columns for the Session table
		SessionID int identity,
		[Date] date not null,
		TimeStart time not null,
		TimeEnd time not null,
		RoomID int not null,
		ClientID int not null,
		SubjectID int not null,
		TutorID int not null,
		SessionMeetingDayID int not null,
		-- Constraints on the Session table
		CONSTRAINT PK_Session PRIMARY KEY (SessionID),
		CONSTRAINT FK1_Session FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
		CONSTRAINT FK2_Session FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
		CONSTRAINT FK3_Session FOREIGN KEY (SubjectID) REFERENCES [Subject](SubjectID),
		CONSTRAINT FK4_Session FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
		CONSTRAINT FK5_Session FOREIGN KEY (SessionMeetingDayID) REFERENCES SessionMeetingDay(SessionMeetingDayID)
)
-- End creating the Session table

	-- Creating the Check table
	CREATE TABLE [Check] (
		-- Columns for the Check table
		CheckID int identity,
		CheckNumber varchar(20) not null,
		DateIssued date not null,
		Amount money not null,
		TutorID int not null,
		-- Constraints on the Check table
		CONSTRAINT PK_Check PRIMARY KEY (CheckID),
		CONSTRAINT FK1_Check FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID)
)
-- End creating the Check table


/*
	Section: Data Creation

	Action: Building INSERT statements and stored procedures to populate 
	our newly created tables with business data. Tables will be populated in the same order they were created.
	The first 5 INSERTs will be created using the defaults that SQL provides for the primary keys; the last 5
	INSERTs will be created NOT using the default settings and hardcoding that value into the column.

*/

-- Adding Data to the Client table
INSERT INTO Client(FirstName, MiddleInitial, LastName, EmailAddress)
VALUES
('Morgan',null, 'Johnson', 'mjo@dodomain.xyz'),
('Donovan','J', 'Mitchell', 'dmit@dodomain.xyz'),
('Dominique','D', 'Doe', 'ddoe@dodomain.xyz'),
('Clark',null, 'Kent', 'cke@dodomain.xyz'),
('Peter', 'P', 'Parker', 'ppar@dodomain.xyz'),
('Joe','N', 'Shmo', 'jshmo@dodomain.xyz')

-- Adding Data to the Subject table
INSERT INTO [Subject](SubjectName, GradeLevel)
VALUES
('Math', '6th'),
('Math', '3rd'),
('English', '3rd'),
('English', '6th'),
('Math', '8th')

-- Adding Data to the Tutor table
INSERT INTO Tutor(FirstName, MiddleInitial, LastName, EmailAddress)
VALUES
('Darrell','L', 'Nelson II', 'dnel@dodomain.xyz'),
('Hannah','T', 'Turner', 'hturner@dodomain.xyz'),
('Isaac','J', 'Curry', 'icur@dodomain.xyz'),
('Nikolaus', null, 'Claus', 'nclaus@dodomain.xyz')

--Adding Data to the ClientSubject table
/* A select statement needs to be embedded into the INSERT statement in order to properly look up
 the PKs from other tables. Email Address is the proper way to look up clients in the client table
 since that is the only unique attribute in that table. Both SubjectName and GradeLevel are required to
 properly identify the SubjectID */

INSERT INTO ClientSubject (ClientID, SubjectID)
VALUES ((SELECT ClientID FROM Client WHERE EmailAddress='mjo@dodomain.xyz'),
(SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='6th')), 
((SELECT ClientID FROM Client WHERE EmailAddress='mjo@dodomain.xyz'),
(SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='6th')),
((SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'),
(SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd')),
((SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'), 
(SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='3rd')),
((SELECT ClientID FROM Client WHERE EmailAddress='jshmo@dodomain.xyz'), 
(SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='8th'))

--Adding Data to the ClientTutor table
/* A select statement needs to be embedded into the INSERT statement in order to properly look up
 the PKs from other tables. Email Address is the proper way to look up clients/tutors in their respective
 tables since it is a unique attribute. */

INSERT INTO ClientTutor (ClientID, TutorID)
VALUES ((SELECT ClientID FROM Client WHERE EmailAddress='mjo@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz')), 
((SELECT ClientID FROM Client WHERE EmailAddress='mjo@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='icur@dodomain.xyz')),
((SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz')),
((SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='icur@dodomain.xyz')),
((SELECT ClientID FROM Client WHERE EmailAddress='ddoe@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='hturner@dodomain.xyz')),
((SELECT ClientID FROM Client WHERE EmailAddress='jshmo@dodomain.xyz'),
(SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'))

/* All PKs for the rest of the tables will now be manually inserted instead
of relying on SQL to provide defaults. */

-- Adding Data to the Room table using 

-- Turn on the identity insert for the Room section
SET IDENTITY_INSERT Room ON;
GO

INSERT INTO Room(RoomID, RoomNumber, SubjectID)
VALUES (1, '1A', (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='6th' )),
(2,'1B', (SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd')),
(3,'1C', (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='3rd'))

-- Turn off the identity insert for the Room section
SET IDENTITY_INSERT Room OFF;
GO

-- Adding Data to the SessionMeetingDay table using 

-- Turn on the identity insert for the SessionMeetingDay section
SET IDENTITY_INSERT SessionMeetingDay ON;
GO

INSERT INTO SessionMeetingDay(SessionMeetingDayID, [DayOfWeek])
VALUES (1, 'Monday'),
(2, 'Tuesday'),
(3, 'Wednesday'),
(4, 'Thursday'),
(5, 'Friday'),
(6, 'Saturday'),
(7, 'Sunday')


-- Turn off the identity insert for the SessionMeetingDay section
SET IDENTITY_INSERT SessionMeetingDay OFF;
GO

-- Adding Data to the TutorSubject table using 

-- Turn on the identity insert for the TutorSubject section
SET IDENTITY_INSERT TutorSubject ON;
GO

INSERT INTO TutorSubject(TutorSubjectID, TutorRate, TutorID, SubjectID)
VALUES (1, 25, (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='6th' )),
(2, 20, (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd' )),
(3, 30, (SELECT TutorID FROM Tutor WHERE EmailAddress='hturner@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='8th' )),
(4, 15, (SELECT TutorID FROM Tutor WHERE EmailAddress='icur@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd' ))

-- Turn off the identity insert for the TutorSubject section
SET IDENTITY_INSERT TutorSubject OFF;
GO

-- Adding Data to the Session table using 

-- Turn on the identity insert for the Session section
SET IDENTITY_INSERT [Session] ON;
GO

INSERT INTO [Session](SessionID, [Date], TimeStart, TimeEnd, RoomID, ClientID, SubjectID, TutorID, SessionMeetingDayID)
VALUES (1, '12/3/2016', '16:00', '17:00', (SELECT RoomID FROM Room WHERE RoomNumber='1A'),
 (SELECT ClientID FROM Client WHERE EmailAddress='mjo@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='6th'),
 (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SessionMeetingDayID FROM SessionMeetingDay WHERE [DayOfWeek]='Monday')),


 (2, '12/4/2016', '13:00', '14:30', (SELECT RoomID FROM Room WHERE RoomNumber='1B'),
 (SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd'),
 (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SessionMeetingDayID FROM SessionMeetingDay WHERE [DayOfWeek]='Tuesday')),

 (3, '12/4/2016', '16:00', '17:00', (SELECT RoomID FROM Room WHERE RoomNumber='1C'),
 (SELECT ClientID FROM Client WHERE EmailAddress='dmit@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='3rd'),
 (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SessionMeetingDayID FROM SessionMeetingDay WHERE [DayOfWeek]='Tuesday')),

  (4, '12/5/2016', '16:00', '17:00', (SELECT RoomID FROM Room WHERE RoomNumber='1A'),
 (SELECT ClientID FROM Client WHERE EmailAddress='jshmo@dodomain.xyz'),
 (SELECT SubjectID FROM [Subject] WHERE SubjectName='Math' AND GradeLevel='3rd'),
 (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz'),
 (SELECT SessionMeetingDayID FROM SessionMeetingDay WHERE [DayOfWeek]='Thursday'))

-- Turn off the identity insert for the Session section
SET IDENTITY_INSERT Session OFF;
GO

-- Adding Data to the Check table using 

-- Turn on the identity insert for the Check section
SET IDENTITY_INSERT [Check] ON;
GO

INSERT INTO [Check](CheckID, CheckNumber, DateIssued, Amount, TutorID)
VALUES (1, '123456789', '11/16/2018', '125.00', (SELECT TutorID FROM Tutor WHERE EmailAddress='dnel@dodomain.xyz')),
	   (2, '112233441', '11/9/2018', '135.00', (SELECT TutorID FROM Tutor WHERE EmailAddress='hturner@dodomain.xyz')),
	   (3, '142536482', '12/2/2018', '200.00', (SELECT TutorID FROM Tutor WHERE EmailAddress='icur@dodomain.xyz'))


-- Turn off the identity insert for the Check section
SET IDENTITY_INSERT [Check] OFF;
GO

/*
	Section: Data Manipulation

	Action: Building 3 UPDATE statements and 3 DELETE statements that tie into company business rules. 
*/

-- UPDATE #1: Email address for client, Peter Parker, has changed. One of our business rules is that each 
-- client MUST have a unique email address in our system.

UPDATE Client SET EmailAddress = 'notspiderman@dodomain.xyz'
WHERE EmailAddress='ppar@dodomain.xyz'

-- UPDATE #2: Tutor, Isaac, raised his rate to teach 3rd grade engligh from $15 to $25 an hour

UPDATE TutorSubject SET TutorRate = 25
WHERE TutorRate=15 AND TutorID = (SELECT TutorID FROM Tutor WHERE EmailAddress='icur@dodomain.xyz')
AND SubjectID = (SELECT SubjectID FROM [Subject] WHERE SubjectName='English' AND GradeLevel='3rd' )

-- UPDATE #3: Tutor, Hannah, got married and wants to change her last name in the database. 

UPDATE Tutor SET LastName = 'Myers'
WHERE EmailAddress = 'hturner@dodomain.xyz'

-- DELETE #1: The session with the client Joe is being canceled due to illness

DELETE FROM [Session] WHERE [Date] = '12/5/2016' AND TimeStart = '16:00' 
AND ClientID =  (SELECT ClientID FROM Client WHERE EmailAddress='jshmo@dodomain.xyz');

-- DELETE #2: Tutor, Mr. Claus has decided to terminate his arrangement with Community Tutors, LLC.

DELETE FROM Tutor WHERE EmailAddress = 'nclaus@dodomain.xyz';

-- DELETE #3: Community Tutors has decided to close on Sundays

DELETE FROM SessionMeetingDay WHERE [DayOfWeek] = 'Sunday';

/*
	Section: Answering Data Questions

	Action: Create SELECT statements that answer the 6 data questions presented in the 'IST-659 M402 Final Project' document.
	The answers to these questions will provide key insights into our business process and highlight potential areas for 
	improvement.
*/

-- Question #1:	Which tutoring subject is the most popular?
-- Identifies highest demand on our resources (classroom, supplies, tutors, etc.)

SELECT TOP 1
Subject.SubjectName,
COUNT(ClientSubject.SubjectID) AS ClientDemand FROM ClientSubject
JOIN [Subject] ON Subject.SubjectID = ClientSubject.SubjectID
GROUP BY Subject.SubjectName
ORDER BY ClientDemand DESC
GO

/* EXPLAINATION:  Counting all the SubjectIDs with same values in the ClientSubject table is the most appropriate way 
	to get an accurate count of all the subjects are clients are getting tutuored in. I also pulled
	SubjectName from the Subject table to view which Subject had the highest count. */


-- Question #2:	Which tutor is the most/least popular?
-- Identifies teaching styles that are the most/least effective with our clients

WITH StudentCounts
AS
(
      SELECT TutorID, COUNT(ClientTutor.ClientID) AS NumOfStudents
      FROM  ClientTutor
      GROUP BY TutorID
),
StudentCountsMinMax
AS
(
      SELECT MIN(NumOfStudents) AS MinNumOfStudents,
            MAX(NumOfStudents) AS MaxNumOfStudents
      FROM  StudentCounts
)
SELECT TU.FirstName, TU.LastName, SC.NumofStudents,
      CASE SC.NumOfStudents WHEN MM.MinNumOfStudents THEN 'Lowest' ELSE 'Highest' END AS [Rank]
FROM  StudentCounts AS SC
INNER JOIN StudentCountsMinMax AS MM ON SC.NumOfStudents IN (MM.MinNumOfStudents, MM.MaxNumOfStudents)
INNER JOIN Tutor AS TU ON TU.TutorID = SC.TutorID
/* EXPLAINATION:  Counting all the ClientIDs in table ClientTutor and grouping them by TutorID returns the total 
amount of clients that have been scheduled to meet or have meeten with a particular tutor in the past. Creating an
alias column that accepts integer values allows us to look at the min/max # of students in the list of tutors.
A "WHEN" clause allows us to display the min calculation as 'Lowest' in a column called StudentCounts and the max
calculatoin as 'Highest in a column.' */


 -- Question #3:	What day of the week has the highest demand?
-- Identifies potential bottlenecks in scheduling

SELECT
SessionMeetingDay.DayOfWeek,
 Count(SessionID) as NumOfSessions FROM [Session]
 JOIN SessionMeetingDay ON SessionMeetingDay.SessionMeetingDayID = Session.SessionMeetingDayID
 GROUP BY SessionMeetingDay.DayOfWeek
GO
/* EXPLAINATION:  Counting all the SessionIDs in the same DayOfWeek column is the most appropriate way 
	to get an accurate count of all the sessions taking place each day in the week. I didn't use the "Top 1"
	function to only select the best value because I believe it makes more business sense to see how all of 
	the days of the week fair against each other. There will always be 7 days in a week so this table output
	should be appropriate at all times in the near future.  
	*/


-- Question #4:	What are the average hours of tutoring per client?
-- Allows us to forecast resource requirements based on client growth 

SELECT
COUNT(Session.ClientID) as ActiveClients,
AVG(DATEDIFF(n, TimeStart, TimeEnd)) as AvgMinutesInSession
FROM Client
 JOIN [Session] ON Session.ClientID = Client.ClientID
GO
/* EXPLAINATION:  Counting all the ClientIDs that are enrolled in sessions will return the total number 
of active clients. Taking difference of the start and stop times of each session using DATEDIFF and averaging
them returns the average time spent in minutes of each client in a session.
*/


-- Question #5:	What is the average tutor rate ($/hour charged to clients)?
-- Identifies what new & unexperienced tutors should charge

SELECT
COUNT(TutorSubject.TutorID) as NumOfTutors,
AVG(TutorSubject.TutorRate) as AvgTutorRate
FROM TutorSubject
GO
/* EXPLAINATION:  Counting all the TutorIDs and averaging their TutorRate in the TutorSubject table
is the most efficient way to calculate what our tutors charge on average per hour.
*/
