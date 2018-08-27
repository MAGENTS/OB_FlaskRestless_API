-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Oswald Ramirez
-- Create date: 08/16/2018
-- Description:	Input JobName for most recen execution details
-- =============================================
CREATE PROCEDURE [dbo].[USP_JobExec]
	-- Add the parameters for the stored procedure here
	@pJobName nvarchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @startdt date,@enddt date,@jobnextexecution date

	print @pJobName

	select 
		@startdt=JobNextStartWindow,
		@enddt=jobnextendwindow,
		@jobnextexecution=JobNextExecution
	from  ControlDB.dbo.CTL_JobExecution
	where joblastexecution in 
	( 
		select max(joblastexecution)
		from ControlDB.dbo.CTL_JobExecution
		where JobName = @pJobName
	)
	and jobname = @pJobName;

	print @startdt
	print @enddt
	print @jobnextexecution

END
GO
