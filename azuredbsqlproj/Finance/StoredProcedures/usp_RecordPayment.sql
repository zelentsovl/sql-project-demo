CREATE PROCEDURE [Finance].[usp_RecordPayment]
    @InvoiceId BIGINT,
    @PaymentReference VARCHAR(60),
    @PaymentMethod VARCHAR(20),
    @Amount DECIMAL(19, 4),
    @RecordedBy NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Amount <= 0
        THROW 50020, 'Payment amount must be greater than zero.', 1;

    BEGIN TRANSACTION;

    DECLARE @InvoiceTotal DECIMAL(19, 4);
    DECLARE @ExistingPayments DECIMAL(19, 4);

    SELECT @InvoiceTotal = [TotalAmount]
    FROM [Finance].[Invoice] WITH (UPDLOCK, HOLDLOCK)
    WHERE [InvoiceId] = @InvoiceId
      AND [InvoiceStatus] <> 'Void';

    IF @InvoiceTotal IS NULL
        THROW 50021, 'The invoice is missing or void.', 1;

    SELECT @ExistingPayments = COALESCE(SUM([Amount]), 0)
    FROM [Finance].[Payment]
    WHERE [InvoiceId] = @InvoiceId;

    IF @ExistingPayments + @Amount > @InvoiceTotal
        THROW 50022, 'Payment would exceed the invoice balance.', 1;

    INSERT [Finance].[Payment]
    (
        [InvoiceId],
        [PaymentReference],
        [PaymentMethod],
        [Amount],
        [RecordedBy]
    )
    VALUES
    (
        @InvoiceId,
        @PaymentReference,
        @PaymentMethod,
        @Amount,
        @RecordedBy
    );

    UPDATE [Finance].[Invoice]
    SET [InvoiceStatus] =
        CASE
            WHEN @ExistingPayments + @Amount = @InvoiceTotal THEN 'Paid'
            ELSE 'PartiallyPaid'
        END
    WHERE [InvoiceId] = @InvoiceId;

    COMMIT TRANSACTION;

    SELECT
        [InvoiceId],
        [InvoiceNumber],
        [InvoiceStatus],
        [TotalAmount]
    FROM [Finance].[Invoice]
    WHERE [InvoiceId] = @InvoiceId;
END;