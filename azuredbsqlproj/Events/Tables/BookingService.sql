CREATE TABLE [Events].[BookingService]
(
    [BookingServiceId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventBookingId] BIGINT NOT NULL,
    [ServiceId] INT NOT NULL,
    [Quantity] DECIMAL(12, 2) NOT NULL,
    [UnitPrice] DECIMAL(19, 4) NOT NULL,
    [DiscountAmount] DECIMAL(19, 4) NOT NULL
        CONSTRAINT [DF_BookingService_DiscountAmount] DEFAULT (0),
    [LineTotal] AS (([Quantity] * [UnitPrice]) - [DiscountAmount]) PERSISTED,
    CONSTRAINT [PK_BookingService] PRIMARY KEY CLUSTERED ([BookingServiceId]),
    CONSTRAINT [UQ_BookingService_EventService] UNIQUE ([EventBookingId], [ServiceId]),
    CONSTRAINT [FK_BookingService_EventBooking] FOREIGN KEY ([EventBookingId])
        REFERENCES [Events].[EventBooking] ([EventBookingId]),
    CONSTRAINT [FK_BookingService_ServiceCatalog] FOREIGN KEY ([ServiceId])
        REFERENCES [Events].[ServiceCatalog] ([ServiceId]),
    CONSTRAINT [CK_BookingService_Quantity] CHECK ([Quantity] > 0),
    CONSTRAINT [CK_BookingService_UnitPrice] CHECK ([UnitPrice] >= 0),
    CONSTRAINT [CK_BookingService_Discount]
        CHECK ([DiscountAmount] >= 0 AND [DiscountAmount] <= ([Quantity] * [UnitPrice]))
);