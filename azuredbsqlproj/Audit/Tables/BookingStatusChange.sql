CREATE TABLE [Audit].[BookingStatusChange]
(
    [BookingStatusChangeId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventBookingId] BIGINT NOT NULL,
    [PreviousStatusCode] VARCHAR(20) NULL,
    [NewStatusCode] VARCHAR(20) NOT NULL,
    [ChangedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_BookingStatusChange_ChangedAtUtc] DEFAULT (SYSUTCDATETIME()),
    [ChangedBy] NVARCHAR(256) NOT NULL
        CONSTRAINT [DF_BookingStatusChange_ChangedBy] DEFAULT (ORIGINAL_LOGIN()),
    CONSTRAINT [PK_BookingStatusChange] PRIMARY KEY CLUSTERED ([BookingStatusChangeId])
);