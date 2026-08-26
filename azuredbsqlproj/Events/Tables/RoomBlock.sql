CREATE TABLE [Events].[RoomBlock]
(
    [RoomBlockId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventBookingId] BIGINT NOT NULL,
    [RoomType] NVARCHAR(80) NOT NULL,
    [CheckInDate] DATE NOT NULL,
    [CheckOutDate] DATE NOT NULL,
    [RoomsPerNight] SMALLINT NOT NULL,
    [NightlyRate] DECIMAL(19, 4) NOT NULL,
    [EstimatedTotal] AS
        (CONVERT(DECIMAL(19, 4), DATEDIFF(DAY, [CheckInDate], [CheckOutDate]) * [RoomsPerNight]) * [NightlyRate]) PERSISTED,
    CONSTRAINT [PK_RoomBlock] PRIMARY KEY CLUSTERED ([RoomBlockId]),
    CONSTRAINT [FK_RoomBlock_EventBooking] FOREIGN KEY ([EventBookingId])
        REFERENCES [Events].[EventBooking] ([EventBookingId]),
    CONSTRAINT [CK_RoomBlock_Dates] CHECK ([CheckOutDate] > [CheckInDate]),
    CONSTRAINT [CK_RoomBlock_Rooms] CHECK ([RoomsPerNight] > 0),
    CONSTRAINT [CK_RoomBlock_Rate] CHECK ([NightlyRate] >= 0)
);