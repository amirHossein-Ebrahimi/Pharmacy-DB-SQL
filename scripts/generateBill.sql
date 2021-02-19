DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
SELECT
	[dbo].[Customer].[nid],
	[dbo].[Customer].[insuranceID],
	[dbo].[Order].[orderID]
FROM [dbo].[Order]
INNER JOIN [dbo].[Prescription]
ON [dbo].[Order].[prescriptionID] = [dbo].[Prescription].[prescriptionID]
INNER JOIN [dbo].[Customer]
ON [dbo].[Prescription].[nid] = [dbo].[Customer].[nid];

DECLARE @n [char](10), @i bigint, @o int;
DECLARE @total_amount int = 0,
			@company_percentage NUMERIC(5,2),
			@insurance_payment int = 0,
			@customer_payment int = 0;

OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR INTO @n, @i, @o;
WHILE @@FETCH_STATUS = 0
BEGIN

    BEGIN TRY
		SELECT @total_amount = SUM([price])
		FROM [dbo].[OrderedDrugs]
		WHERE [orderID] = @o;

		IF @i IS NOT NULL BEGIN
			SELECT @company_percentage = [coinsurance]
			FROM [dbo].[Insurance]
			WHERE [id] = @i;

			-- Incsurance will pay
			SET @insurance_payment = CONVERT(INT, @total_amount * @company_percentage / 100);
			-- Customer will pay the rest
			SET @customer_payment = @total_amount - @insurance_payment;
		END
		ELSE BEGIN
			SET @insurance_payment = 0;
			SET @customer_payment = @total_amount;
		END

		-- Insert to bill
		INSERT INTO [dbo].[Bill]
		(orderID, customerNID, totalPayment, customerPayment, insurancePayment)
		VALUES
		(@o, @n, @total_amount, @customer_payment, @insurance_payment)
		FETCH NEXT FROM MY_CURSOR INTO @n, @i, @o;
    END TRY
    BEGIN CATCH
		FETCH NEXT FROM MY_CURSOR INTO @n, @i, @o;
    END CATCH
END
CLOSE MY_CURSOR;
DEALLOCATE MY_CURSOR;