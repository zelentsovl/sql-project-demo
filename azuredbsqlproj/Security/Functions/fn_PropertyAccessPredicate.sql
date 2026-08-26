CREATE FUNCTION [Security].[fn_PropertyAccessPredicate]
(
    @PropertyId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS [fn_accessResult]
    WHERE @PropertyId = TRY_CONVERT(INT, SESSION_CONTEXT(N'PropertyId'))
);
GO