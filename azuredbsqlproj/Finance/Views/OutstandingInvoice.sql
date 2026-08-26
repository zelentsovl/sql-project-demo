CREATE VIEW [Finance].[OutstandingInvoice]
AS
SELECT
    invoice.[InvoiceId],
    invoice.[InvoiceNumber],
    booking.[EventNumber],
    booking.[EventName],
    property.[PropertyCode],
    invoice.[IssuedDate],
    invoice.[DueDate],
    invoice.[CurrencyCode],
    invoice.[TotalAmount],
    COALESCE(payment.[PaidAmount], 0) AS [PaidAmount],
    invoice.[TotalAmount] - COALESCE(payment.[PaidAmount], 0) AS [BalanceAmount],
    invoice.[InvoiceStatus]
FROM [Finance].[Invoice] AS invoice
INNER JOIN [Events].[EventBooking] AS booking
    ON booking.[EventBookingId] = invoice.[EventBookingId]
INNER JOIN [Resort].[Property] AS property
    ON property.[PropertyId] = booking.[PropertyId]
OUTER APPLY
(
    SELECT SUM([Amount]) AS [PaidAmount]
    FROM [Finance].[Payment]
    WHERE [InvoiceId] = invoice.[InvoiceId]
) AS payment
WHERE invoice.[InvoiceStatus] IN ('Open', 'PartiallyPaid');