use Insurance
go

---Out standing publish
Declare @DateAsOf Date
Set @DateAsOf = '1/1/2019'

Declare @ReservingToolPbl Table(
	ClaimNumber Varchar(30)
	,LastPublishDate Datetime
)
Insert into @ReservingToolPbl
Select ClaimNumber,  max(EnteredOn) as LastDatePublished
From ReservingTool
where IsPublished = 1
Group by ClaimNumber



Declare @AssignedDateLog Table(
	PK int
	,ExaminerAssignedDate Datetime
)
Insert into @AssignedDateLog
Select PK, max(EntryDate) as ExaminerAssingedDate
From ClaimLog
Where FieldName = 'ExaminerCode'
Group by PK

--Select * from @AssignedDateLog
--Select * from @ReservingToolPbl

---Part 2 + 3---
Select ClaimNumber
		,ExaminerCode
		,ExaminerName
		,ExaminerTitle
		,ManagerCode
		,ManagerName
		,ManagerTitle
		,SupervisorCode
		,SupervisorName
		,SupervisorTitle
		,OfficeDesc
		,ClaimStatusDesc
		,ClaimentName
		,ClaimantTypeDesc
		,ExaminerAssignedDate
		,ReopenedDate
		,AdjustAssignedDate
		,LastPublishDate
		,DaysSinceLastPublishDate
		,DaysSinceAdjustAssignedDate
		,case when DaysSinceAdjustAssignedDate > 14 And DaysSinceLastPublishDate >90 then 0
			when 91 - DaysSinceLastPublishDate >=15 -DaysSinceAdjustAssignedDate
				then 91 - DaysSinceLastPublishDate
			else 15 - DaysSinceAdjustAssignedDate
		 end as DaysToComplete
		 ,case when DaysSinceAdjustAssignedDate <= 14 or DaysSinceLastPublishDate <=90 then 0
			when DaysSinceLastPublishDate - 90  <= DaysSinceAdjustAssignedDate -14
				then DaysSinceLastPublishDate - 90
			else DaysSinceAdjustAssignedDate -14
		 end as DaysOverdue
		 
From(
Select 
		C.ClaimNumber
		,O.OfficeDesc
		,O.State
		,U.UserName as ExaminerCode
		,User2.UserName as SupervisorCode
		,User3.UserName as ManagerCode
		,U.LastFirstName as ExaminerName
		,User2.LastFirstName as SupervisorName
		,User3.LastFirstName as ManagerName
		,U.Title as ExaminerTitle
		,User2.Title as SupervisorTitle
		,User3.Title as ManagerTitle
		,cs.ClaimStatusDesc
		,P.LastName + ' ' + trim(P.FirstName + ' ' + P.MiddleName) as ClaimentName
		,Cl.ReopenedDate
		,U.ReserveLimit
		,R.ReserveAmount
		,CT.ClaimantTypeDesc
		,ADL.ExaminerAssignedDate
		,RTP.LastPublishDate
		,Case when CS.ClaimStatusDesc = 'Re-Open' And Cl.ReopenedDate > ADL.ExaminerAssignedDate then Cl.ReopenedDate
			Else ADL.ExaminerAssignedDate
			End as AdjustAssignedDate
		,Case when CS.ClaimStatusDesc = 'Re-Open' And Cl.ReopenedDate > ADL.ExaminerAssignedDate 
			Then Datediff(day, ReopenedDate, @DateAsOf)
			Else Datediff(day, ExaminerAssignedDate, @DateAsOf)
			End as DaysSinceAdjustAssignedDate
		,(Case 
			When RT.ParentID in (1,2,3,4,5) then RT.ParentID
			else RT.reserveTypeID
			end) as ReserveCostID
		,DATEDIFF(day, LastPublishDate, @DateAsOf) as DaysSinceLastPublishDate
From Claimant cl
inner join Claim C on c.ClaimID = cl.ClaimID
inner join Users U on U.UserName = C.ExaminerCode
inner join Users User2 on U.Supervisor = User2.UserName
inner join Users User3 on U.Supervisor = User3.UserName
inner join Office O on U.OfficeID = O.OfficeID
inner join ClaimantType CT on CT.ClaimantTypeID = cl.ClaimantTypeID
inner join Reserve R on R.ClaimantID = cl.ClaimantID
inner join ClaimStatus CS on CS.ClaimStatusID = cl.ClaimStatusID
inner join ReserveType RT on RT.reserveTypeID = R.ReserveTypeID
inner join Patient P on P.PatientID = CL.PatientID
inner join @AssignedDateLog ADL on C.ClaimID = ADL.PK
left join @ReservingToolPbl RTP on C.ClaimNumber = RTP.ClaimNumber
where O.OfficeDesc in ('Sacramento', 'San Francisco', 'San Diego')
	And (RT.ParentID in (1,2,3,4,5) or rt.reserveTypeID in (1,2,3,4,5))
	And (CS.ClaimStatusID = 1 or (CS.ClaimStatusID = 2 and CL.ReopenedReasonID <>3))
	And cl.ReopenedDate is not null
) BaseData

Pivot(
Sum(ReserveAmount)
	For ReserveCostID in ([1],[2],[3],[4],[5])) PivotTable
where PivotTable.ClaimantTypeDesc in ('First Aid', 'Medical-Only')
	Or (PivotTable.OfficeDesc in ('San Diego') 
		and isnull([1],0) + isnull([2],0) + isnull([3],0) + isnull([4],0) + isnull([5],0) >= PivotTable.ReserveLimit)
	Or (PivotTable.OfficeDesc in ('Sacremento','San Francisco') 
		And (isnull([1],0) > 800
			or isnull([5],0) > 1100 
			or isnull([2],0) > 0 or isnull([3],0) > 0 or isnull([4],0) > 0)
			)



