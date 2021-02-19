DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
SELECT
    [dbo].[Order].[orderID],
    [dbo].[Drug].[name],
    [dbo].[PrescribedDrugs].[prescribedQuantity],
    [dbo].[Drug].[price],
    [dbo].[Drug].[batchNumber]
FROM [dbo].[Order]
INNER JOIN [dbo].[PrescribedDrugs]
ON [dbo].[PrescribedDrugs].[prescriptionID] =  [dbo].[Order].[prescriptionID]
INNER JOIN [dbo].[Drug]
ON [dbo].[PrescribedDrugs].[drugName] = [dbo].[Drug].[name]
ORDER BY  [dbo].[Drug].[stockQuantity];

DECLARE @o bigint, @n nvarchar(255), @oq int, @p int, @b int;
OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR INTO @o, @n, @oq, @p, @b;
WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		INSERT INTO
		[dbo].[OrderedDrugs] ([orderID],[drugName],[orderedQuantity],[price],[batchNumber])
		VALUES
		(@o, @n, @oq, @p, @b);
		FETCH NEXT FROM MY_CURSOR INTO @o, @n, @oq, @p, @b;
	END TRY
	BEGIN CATCH
		FETCH NEXT FROM MY_CURSOR INTO @o, @n, @oq, @p, @b;
	END CATCH
END
CLOSE MY_CURSOR;
DEALLOCATE MY_CURSOR;