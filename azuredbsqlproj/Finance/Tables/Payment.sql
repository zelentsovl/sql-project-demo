CREATE TABLE [Finance].[Payment]
(
    [PaymentId] BIGINT IDENTITY(1, 1) NOT NULL,
    [InvoiceId] BIGINT NOT NULL,
    [PaymentReference] VARCHAR(60) NOT NULL,
    [PaymentDateUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Payment_PaymentDateUtc] DEFAULT (SYSUTCDATETIME()),
    [PaymentMethod] VARCHAR(20) NOT NULL,
    [Amount] DECIMAL(19, 4) NOT NULL,
    [RecordedBy] NVARCHAR(256) NOT NULL
        CONSTRAINT [DF_Payment_RecordedBy] DEFAULT (ORIGINAL_LOGIN()),
    CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED ([PaymentId]),
    CONSTRAINT [UQ_Payment_PaymentReference] UNIQUE ([PaymentReference]),
    CONSTRAINT [FK_Payment_Invoice] FOREIGN KEY ([InvoiceId])
        REFERENCES [Finance].[Invoice] ([InvoiceId]),
    CONSTRAINT [CK_Payment_Method]
        CHECK ([PaymentMethod] IN ('BankTransfer', 'CreditCard', 'DigitalWallet', 'Other')),
    CONSTRAINT [CK_Payment_Amount] CHECK ([Amount] > 0)
);