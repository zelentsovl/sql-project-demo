CREATE TYPE [Events].[BookingServiceLineType] AS TABLE
(
    [ServiceId] INT NOT NULL,
    [Quantity] DECIMAL(12, 2) NOT NULL,
    [DiscountAmount] DECIMAL(19, 4) NULL,
    PRIMARY KEY ([ServiceId])
);