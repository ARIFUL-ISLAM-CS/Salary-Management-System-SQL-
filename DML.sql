Drop database Salary_Management_System
go
create database Salary_Management_System
on primary
(name=N'Salary_Data_1', 
filename=N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Salary_Data_1.mdf',
size=25mb,
maxsize=100mb,
filegrowth=5%)
log on
(name=N'Salary_Log_1',
filename=N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Salary_Log_1.ldf',
size=2mb,
maxsize=25mb,
filegrowth=1%);
go
use Salary_Management_System
go
go
insert into Department
values ('Accounce'),
('IT'),
('HR'),
('Marketing');
go
insert into Designation
values ('Head'),
('executive'),
('Senior executive'),
('Manager'),
('Asst. Manager'),
('Analyst'),
('Programer'),
('Professional');
go
insert into Employee_Details
values ('Mr.','Barkar',12-12-2016,01-01-1980,'Dhaka','barkar1020@gmail.com',0099232442,50000,.15),
('Mr.','Zuzu',8-8-2017,01-01-1988,'CTG','Zuzu1020@gmail.com',0099231442,20000,.15),
('Mr.','Fanil',01-01-2014,01-01-1987,'RANGPUR','Fanil1020@gmail.com',0099832442,30000,.15),
('Mr.','Mars',12-9-2015,01-01-1986,'Dhaka','Mars1020@gmail.com',0099242442,45000,.15),
('Mr.','Sarkar',22-12-2019,01-01-1990,'CTG','Sarkar1020@gmail.com',0049232442,40000,.15),
('Mr.','Danil',2-12-2017,01-01-1992,'COMILLA','Danil@gmail.com',0096232442,40000,.15),
('Mr.','Gorg',12-2-2018,01-01-1993,'COMILLA','Gorg@gmail.com',0099252442,35000,.15),
('Mr.','Hax',12-10-2013,01-01-1994,'RANGPUR','Hax@gmail.com',0099233442,30000,.15);
go
insert into RelationalDD_Table
values (1001,200,103),
(1002,201,104),
(1003,202,104),
(1004,203,101),
(1005,204,101),
(1006,205,102),
(1007,206,102),
(1008,207,102);
go
insert into OverTime_Payment
values (10000,11-01-2020),
(15000,20-01-2020);
go
insert into Advanced_Payment
values (5000,18-01-2020),
(5000,18-01-2020);
go
insert into paid_salary
values (05-01-2020,'Paid'),
(06-01-2020,'Paid'),
(07-01-2020,'Paid');
	 
go
insert into Relational_Table(RelationalDD_ID,OverTime_Payment_ID,Advanced_Payment_ID,Paid_Salary_ID)
values (1,null,null,1),
(2,500,1,1),
(3,null,null,2),
(4,null,2,2),
(5,null,1,3),
(6,501,null,1),
(7,null,2,3),
(8,500,null,4);
go
-----SP Insert----------
go
create proc SP_Insert_paid_salary

@Paid_Salary_ID int,
@Salary_Payment_Date Datetime,
@Salary_Paid_Status varchar(50)
as
insert into paid_salary(Paid_Salary_ID,Salary_Payment_Date,Salary_Paid_Status) 
values(@Paid_Salary_ID,@Salary_Payment_Date, @Salary_Paid_Status)
go

execute SP_Insert_paid_salary

execute SP_Insert_paid_salary
go
-----SP Update----------
create proc SP_Update_paid_salary
@Paid_Salary_ID int,
@Salary_Payment_Date Datetime,
@Salary_Paid_Status varchar(50)
as

Update paid_salary set Salary_Paid_Status = @Salary_Paid_Status

where Paid_Salary_ID=@Paid_Salary_ID
go

execute SP_Update_paid_salary 
go
-----SP Delete----------

create proc SP_Delete_paid_salary
@Paid_Salary_ID int
as
delete from Paid_Salary where Paid_Salary_ID=@Paid_Salary_ID
go

execute SP_Delete_paid_salary
go

create function fn_OverTime_Payment
       ()
       returns int
       begin
       DECLARE @c int
       select @c = COUNT(*) from OverTime_Payment;
       return @c;
       end;
GO

-- function view------

select dbo.OverTime_Payment();
go
-- create a simple table-valued function

       create function Fn_OverTime_Payment_v
       ()
       Returns table
       Return
       (
       select * from OverTime_Payment
       );
go