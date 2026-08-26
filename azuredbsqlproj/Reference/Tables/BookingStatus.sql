CREATE TABLE [Reference].[BookingStatus]
(
    [BookingStatusCode] VARCHAR(20) NOT NULL,
    [DisplayName] NVARCHAR(60) NOT NULL,
    [SortOrder] TINYINT NOT NULL,
    [IsTerminal] BIT NOT NULL
        CONSTRAINT [DF_BookingStatus_IsTerminal] DEFAULT (0),
    CONSTRAINT [PK_BookingStatus] PRIMARY KEY CLUSTERED ([BookingStatusCode]),
    CONSTRAINT [UQ_BookingStatus_SortOrder] UNIQUE ([SortOrder])
);