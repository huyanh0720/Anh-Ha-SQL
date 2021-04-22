use Insurance
go
---Update---
Select * from MedicalReserveCases

insert into MedicalReserveCases
select ClaimNumber, MedicalReservingAmount * 2
From ReservingTool

Update MedicalReserveCases
set ClaimNumber = C.NewClaimNUmber
From MedicalReserveCases M
inner join ClaimNumberFixes C on M.ClaimNumber = C.OldClaimNumber

Alter table MedicalReserveCases
Add BestCaseMedicalReserves FLoat

Update MedicalReserveCases
set BestCaseMedicalReserves = Rt.MedicalReservingAmount * 0.5
From MedicalReserveCases M
inner join ReservingTool RT on M.ReservingToolID =  RT.ReservingToolID

--bonus--

select NewValue as StartingUser
into #temp
From ClaimLog
where FieldName = 'ExaminerCode'
	And Oldvalue = 'unassigned'

select * from #temp
drop table #temp

select PK as ClaimID 
	,NewValue as StartingUser
	,Null as FollowingUser
	,0 as Level
into #temp
From ClaimLog
where FieldName = 'ExaminerCode'
	And Oldvalue = 'unassigned'

	---ex #TemporyTables

Create Table #temp 
	(ClaimID int
	,CurrentExaminer varchar(50)
	,PreviousExaminer varchar(50)
	, AssignedDate DateTime
	,level int
	)

insert into #temp
Select CL.PK as ClaimID
		,CL.NewValue as CurrentExaminer
		, Null as PreviousExaminer
		, LastestAssigedDate as AssignedDate
		,0 as level
From(
select PK 
	,max(EntryDate) as LastestAssigedDate
From ClaimLog
where FieldName = 'ExaminerCode'
Group by PK
) x
inner join ClaimLog cl on x.PK = cl.PK 
	and x.LastestAssigedDate = cl.EntryDate 
	and cl.FieldName = 'ExaminerCode'
order by CL.PK

--exercise 1
USE [UPDATE]
GO

Select *
into [dbo].[G&T Results 2017-18_Temp]
From [dbo].[G&T Results 2017-18]

select * from [dbo].[G&T Results 2017-18_Temp]

update [dbo].[G&T Results 2017-18_Temp]
set [Entering Grade Level] = 1
where [Entering Grade Level] is null

---exercise 2
--step1
Update [dbo].[G&T Results 2017-18_Temp]
Set [School Preferences] = replace([School Preferences],'/',',')

--step2 
Select * from [dbo].[G&T Results 2017-18_Temp]
where [Overall Score] = 99 
		and([School Assigned] is null
			or trim([School Assigned]) = 'NONE')
--step3 
update [dbo].[G&T Results 2017-18_Temp]
Set [School Assigned] =
		Case when CHARINDEX (',',[School Preferences], 1) = 0 then [School Preferences]
			Else LEFT([School Preferences], CHARINDEX(',',[School Preferences], 1) -1) 
		End
where [Overall Score] = 99 
		and([School Assigned] is null
			or trim([School Assigned]) = 'NONE')

Select * from [dbo].[G&T Results 2017-18_Temp]
where [Overall Score] = 99 
		and([School Assigned] is null
			or trim([School Assigned]) = 'NONE')


---exercise 3
Select *
into [dbo].[G&T Results 2017-18_Temp1]
from [dbo].[G&T Results 2017-18]
Select * from [G&T Results 2017-18_Temp1]


Delete From [dbo].[G&T Results 2017-18_Temp1]
Where [OLSAT Verbal Score] is null

Select * from ReserveType

insert into [ReserveType]
Values (1 ,'','Fatality Misc.',10)

---Stored Procedures---
---ex1---

Use Insurance
go

select * from Claim
select * from ClaimLog
select * from ReservingTool

Select ClaimNumber, EnteredOn as DatePublish
From ReservingTool
where IsPublished = 1

--ex2--Create each type and divided each type by pivot table
Select * from Claimant
Select * from Claim
Select * from Attachment

Select * From(
	Select C.ClaimNumber
			,A.ClaimantID
			,Right(FileName, 4) as FileType
	From Attachment A
	inner join Claimant cl on A.ClaimantID = cl.ClaimantID
	inner join Claim C on Cl.ClaimID = C.ClaimID
	where right(FileName,4) in ('.pdf','.xls','.doc','.ppt')
	) baseData
Pivot (Count(ClaimantID)
	for FileType in ([.pdf],[.xls],[.doc],[.ppt])
	)PivotTable

---Ex3---
select *
from Ex03_Reserve

select *
from Ex03_Reserve

---ex5 find claim that had published both today and before today '12/31/2016'
Select distinct R1.ClaimNumber
From ReservingTool R1, ReservingTool R2 
where R1.ClaimNumber = R2.ClaimNumber	
	and CONVERT(date, R1.EnteredOn) = '12/31/2016'
	and convert(date, R2.EnteredOn) < '12/31/2016'

	select Top 1 ClaimID
	from claim
	order by ClaimID desc
	
--- Select only date
SELECT  CAST(EntryDate AS DATE)
from Claimant




