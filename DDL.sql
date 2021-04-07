GO
IF DB_ID('Salary_Management_System') IS NOT NULL
drop database Salary_Management_System	
go
create database Salary_Management_System
on primary
(name=N'Salary_Management_System', 
filename=N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Salary_Management_System.mdf',
size=25mb,
maxsize=100mb,
filegrowth=5%)
log on
(name=N'payroll', 
filename=N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Salary_Management_System.ldf',
size=25mb,
maxsize=100mb,
filegrowth=5%);
go
use Salary_Management_System
go
create table Department
(Department_ID int primary key identity(101,1),
Department_Name varchar(20));
go
create table Designation
(Designation_ID int primary key identity (200,1),
Designation_Name varchar(20));
go
create table Employee_Details
(Employee_ID int primary key identity(1001,1),
Employee_FirstName varchar(25),
Employee_LastName varchar(25),
Employee_Joining_Date Datetime,
Employee_Date_Of_Birth Datetime,
Employee_Address varchar(40),
Employee_email varchar(25),
Employee_Contact_No int,
Employee_Basic_Salary money,
Employee_Provident_Fund numeric (3,2));
go
create table RelationalDD_Table
(RelationalDD_ID int primary key identity,
Employee_ID int references Employee_Details(Employee_ID),
Designation_ID int references Designation(Designation_ID),
Department_ID int references Department(Department_ID));
go
create table OverTime_Payment
(OverTime_Payment_ID int primary key identity(500,1),
OverTime_Payment_Amount int,
OverTime_Payment_Date Datetime);
go
create table Advanced_Payment
(Advanced_Payment_ID int primary key identity,
Advanced_Payment_Amount int,
Advanced_Payment_Date Datetime);
go
create table Paid_Salary
(Paid_Salary_ID int primary key identity,
Salary_Payment_Date Datetime,
Salary_Paid_Status varchar(20));
go
create table Relational_Table
(Relational_Id int primary key identity,
RelationalDD_ID int references RelationalDD_Table(RelationalDD_ID),
OverTime_Payment_ID int references OverTime_Payment(OverTime_Payment_ID),
Advanced_Payment_ID int references Advanced_Payment(Advanced_Payment_ID),
Paid_Salary_ID int references Paid_Salary(Paid_Salary_ID));
go
create table Advanced_Payment_Audit
(Advanced_Payment_ID int primary key identity,
Advanced_Payment_Amount int,
Advanced_Payment_Date Datetime,
Activity varchar(10),
DoneBy varchar(20),
ActivityTime datetime);
go
create table Paid_Salary_merge
(Paid_Salary_ID int primary key identity,
Salary_Payment_Date Datetime,
Salary_Paid_Status varchar(20));
go
					--------------------MERGE-----------------

MERGE INTO dbo.Paid_Salary AS p
USING dbo.Paid_Salary_merge AS ps
        ON p.Paid_Salary_ID = ps.Paid_Salary_ID
WHEN MATCHED THEN
    UPDATE SET
      p.Salary_Payment_Date = ps.Salary_Payment_Date,
      p.Salary_Paid_Status = ps.Salary_Paid_Status
WHEN NOT MATCHED THEN 
      INSERT (Paid_Salary_ID, Salary_Payment_Date, Salary_Paid_Status)
      VALUES (ps.Paid_Salary_ID, ps.Salary_Payment_Date, ps.Salary_Paid_Status);

  --------------------MERGE-----------------
	  select * from Paid_Salary
	  select * from Paid_Salary_merge
	  insert into Paid_Salary_merge values(08-01-2020,'Paid')

	 ----------CTE-------------------------------------------------

WITH CTE_Employee_Age (Name, DateOfBirth, CurrentDate, Age) AS (
    SELECT    
        s.Employee_FirstName + ' ' + s.Employee_LastName, 
        s.Employee_Date_Of_Birth,
		GETDATE(),
        YEAR(GETDATE()) - YEAR(s.Employee_Date_Of_Birth)
    FROM Employee_Details s
)
SELECT
    Name, 
    DateOfBirth,
	Age
FROM 
    CTE_Employee_Age
WHERE
    Age <= 150;
	go
	
		--------------------inserted of TRIGGER-----------------

CREATE TRIGGER Advanced_Payment_Audit
ON Advanced_Payment
AFTER UPDATE, INSERT, DELETE
AS
DECLARE @Advanced_Payment_ID INT, @Advanced_Payment_Amount int,@Advanced_Payment_Date Datetime, @activity VARCHAR(10),@user varchar(20);

--UPDATE
IF EXISTS(SELECT * FROM inserted) and exists (SELECT * FROM deleted)
BEGIN
    SET @activity = 'UPDATE';
    SET @user = SYSTEM_USER;
    SELECT @Advanced_Payment_ID = u.Advanced_Payment_ID, @Advanced_Payment_Amount = u.Advanced_Payment_Amount, @Advanced_Payment_Date = u.Advanced_Payment_Date FROM inserted u;
    INSERT INTO Advanced_Payment_Audit(Advanced_Payment_ID,Advanced_Payment_Amount,Advanced_Payment_Date,Activity,DoneBy,ActivityTime)
	VALUES(@Advanced_Payment_ID,@Advanced_Payment_Amount,@Advanced_Payment_Date,@activity,@user,GETDATE());
	PRINT('Trigger fired after UPDATE');
END

--INSERT
IF exists (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    SET @activity = 'INSERT';
    SET @user = SYSTEM_USER;
    SELECT @Advanced_Payment_ID = i.Advanced_Payment_ID, @Advanced_Payment_Amount = i.Advanced_Payment_Amount, @Advanced_Payment_Date = i.Advanced_Payment_Date FROM inserted i;
    INSERT INTO Advanced_Payment_Audit(Advanced_Payment_ID,Advanced_Payment_Amount,Advanced_Payment_Date,Activity,DoneBy,ActivityTime)
	VALUES(@Advanced_Payment_ID,@Advanced_Payment_Amount,@Advanced_Payment_Date,@activity,@user,GETDATE());
	PRINT('Trigger fired after UPDATE');
END

IF EXISTS(select * from deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN
    SET @activity = 'DELETE';
    SET @user = SYSTEM_USER;
    SELECT @Advanced_Payment_ID = d.Advanced_Payment_ID, @Advanced_Payment_Amount = d.Advanced_Payment_Amount, @Advanced_Payment_Date = d.Advanced_Payment_Date FROM inserted d;
    INSERT INTO Advanced_Payment_Audit(Advanced_Payment_ID,Advanced_Payment_Amount,Advanced_Payment_Date,Activity,DoneBy,ActivityTime)
	VALUES(@Advanced_Payment_ID,@Advanced_Payment_Amount,@Advanced_Payment_Date,@activity,@user,GETDATE());
	PRINT('Trigger fired after UPDATE');
END
GO
--------------------TESR TRIGGER-----------------
insert into Advanced_Payment(Advanced_Payment_Amount,Advanced_Payment_Date)
values (56000,12-01-2020),
(5000,18-01-2020);

	--------------------AFTER TRIGGER-----------------
CREATE TRIGGER [dbo].[Trg_OverTime_Payment]
ON [dbo].[OverTime_Payment]
INSTEAD OF UPDATE, INSERT, DELETE
AS
BEGIN
	DECLARE @OverTime_Payment_ID INT, @OverTime_Payment_Amount INT, @OverTime_Payment_Date Datetime
	, @OverTime_Payment_AmountOriginal NVARCHAR(50), @noOfOverTime INT;

	--UPDATE
	IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
	BEGIN
		SELECT @OverTime_Payment_ID = u.OverTime_Payment_ID, @OverTime_Payment_Amount = u.OverTime_Payment_Amount, @OverTime_Payment_Date = u.OverTime_Payment_Date FROM inserted u;
		SELECT @OverTime_Payment_AmountOriginal = o.OverTime_Payment_Amount FROM OverTime_Payment o;
		IF(@OverTime_Payment_Amount <> @OverTime_Payment_AmountOriginal)
		BEGIN
			RAISERROR('Over Time Payment cannot be UPDATE.', 11, 0);
		END
		ELSE
		BEGIN
			UPDATE [OverTime_Payment] SET [OverTime_Payment_Amount] = @OverTime_Payment_Amount WHERE OverTime_Payment_ID = @OverTime_Payment_ID
			PRINT('Over Time Payment Address UPDATE');
		END
	END

	--INSERT
	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
	BEGIN
		SELECT @OverTime_Payment_ID = i.OverTime_Payment_ID, @OverTime_Payment_Amount = i.OverTime_Payment_Amount, @OverTime_Payment_Date = i.OverTime_Payment_Date FROM inserted i;
		SELECT @noOfOverTime = COUNT(o.OverTime_Payment_ID) FROM OverTime_Payment o;
		IF(@noOfOverTime >= 5)
		BEGIN
			RAISERROR('OverTime Payment cannot be INSERT.', 11, 0);
		END
		ELSE
		BEGIN
			INSERT INTO OverTime_Payment(OverTime_Payment_Amount,OverTime_Payment_Date) VALUES(@OverTime_Payment_Amount,@OverTime_Payment_Date)
			PRINT('Over Time Payment INSERT');
		END
	END

	--DELETE
	IF EXISTS(select * from deleted) AND NOT EXISTS(SELECT * FROM inserted)
	BEGIN
		SELECT @OverTime_Payment_ID = d.OverTime_Payment_ID FROM inserted d;
		RAISERROR('Over Time Payment cannot be DELETE.', 11, 0);
	END
END
------------------Test  TRIGGER-----------
SELECT * FROM OverTime_Payment
DELETE FROM OverTime_Payment WHERE OverTime_Payment_ID = 2
UPDATE OverTime_Payment SET OverTime_Payment_Amount = 'D' WHERE OverTime_Payment_ID = 7
INSERT INTO OverTime_Payment(OverTime_Payment_Amount,OverTime_Payment_Date) VALUES(1000,4-02-2020);
GO


		--------------------AFTER TRIGGER-----------------
CREATE TRIGGER dbo.Trg_InsteadOfUpdate_Relational_Table
ON dbo.RelationalDD_Table
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @Relational_Id int, @RelationalDD_ID int, @OverTime_Payment_ID int, @Advanced_Payment_ID int;
	SELECT @Relational_Id = inserted.Relational_Id,
	       @RelationalDD_ID = inserted.RelationalDD_ID,
	       @OverTime_Payment_ID = inserted.OverTime_Payment_ID,
	 	@Advanced_Payment_ID = inserted.Advanced_Payment_ID       
	FROM inserted
	if UPDATE(Relational_Id)
	BEGIN
        RAISERROR('cannot be updated.', 16 ,1)
	    ROLLBACK
	END
	ELSE
	BEGIN
	  UPDATE Relational_Table
	  SET Relational_Id = @Relational_Id 
	  WHERE Relational_Id = @Relational_Id
	END
END

update Relational_Table set Relational_Id = 3 where Relational_Id = 1

