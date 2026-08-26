CREATE TABLE [Finance].[Invoice]
(
    [InvoiceId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventBookingId] BIGINT NOT NULL,
    [InvoiceNumber] VARCHAR(30) NOT NULL,
    [IssuedDate] DATE NOT NULL,
    [DueDate] DATE NOT NULL,
    [CurrencyCode] CHAR(3) NOT NULL,
    [SubtotalAmount] DECIMAL(19, 4) NOT NULL,
    [TaxAmount] DECIMAL(19, 4) NOT NULL
        CONSTRAINT [DF_Invoice_TaxAmount] DEFAULT (0),
    [TotalAmount] AS ([SubtotalAmount] + [TaxAmount]) PERSISTED,
    [InvoiceStatus] VARCHAR(20) NOT NULL
        CONSTRAINT [DF_Invoice_InvoiceStatus] DEFAULT ('Open'),
    [CreatedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Invoice_CreatedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED ([InvoiceId]),
    CONSTRAINT [UQ_Invoice_InvoiceNumber] UNIQUE ([InvoiceNumber]),
    CONSTRAINT [FK_Invoice_EventBooking] FOREIGN KEY ([EventBookingId])
        REFERENCES [Events].[EventBooking] ([EventBookingId]),
    CONSTRAINT [CK_Invoice_Dates] CHECK ([DueDate] >= [IssuedDate]),
    CONSTRAINT [CK_Invoice_Amounts] CHECK ([SubtotalAmount] >= 0 AND [TaxAmount] >= 0),
    CONSTRAINT [CK_Invoice_Status]
        CHECK ([InvoiceStatus] IN ('Open', 'PartiallyPaid', 'Paid', 'Void'))
);