DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
    FOR
SELECT
    [dbo].[Order].[orderID] AS o,
    [dbo].[PrescribedDrugs].[drugName] AS n,
    [dbo].[Drug].[batchNumber] AS l,
    [dbo].[Order].[employeeID] AS e,
    [dbo].[PrescribedDrugs].[prescribedQuantity] AS q
FROM [dbo].[Order]
INNER JOIN ([dbo].[PrescribedDrugs] INNER JOIN [dbo].[Drug] ON [dbo].[PrescribedDrugs].[drugName] = [dbo].[Drug].[name] )
ON [dbo].[Order].[prescriptionID] = [dbo].[PrescribedDrugs].[prescriptionID]
WHERE [dbo].[Drug].[stockQuantity] > [dbo].[PrescribedDrugs].[prescribedQuantity]
ORDER BY [dbo].[PrescribedDrugs].[prescribedQuantity];

DECLARE @n nvarchar(255),
    @l int,
    @o int,
    @e tinyint,
    @q int;

OPEN MY_CURSOR
    WHILE @@FETCH_STATUS = 0
    BEGIN
    BEGIN TRY
        FETCH NEXT FROM MY_CURSOR INTO @o, @n,@l,@e,@q;
        EXECUTE [dbo].[DISPOSE_DRUGS] @n, @l, @e, @q
    END TRY
    BEGIN CATCH
        FETCH NEXT FROM MY_CURSOR INTO @o, @n,@l,@e,@q;
    END CATCH
    END

CLOSE MY_CURSOR;
DEALLOCATE MY_CURSOR;
