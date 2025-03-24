USE [project]
GO

-- индекс на таблице Trips по сотруднику и датам командировки
/****** Object:  Index [IX_Trips_EmpID_Dates]    Script Date: 24.03.2025 19:47:20 ******/
CREATE NONCLUSTERED INDEX [IX_Trips_EmpID_Dates] ON [dbo].[Trips]
(
	[EmployeeID] ASC,
	[StartDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


-- индекс на таблице Expenses по городу командировки + сумма 
CREATE NONCLUSTERED INDEX [IX_Dest_Amount] ON [dbo].[Expenses]
(
	[DestinationID] ASC
)
INCLUDE([Amount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


