CREATE TABLE [Events].[VenueBooking]
(
    [VenueBookingId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventBookingId] BIGINT NOT NULL,
    [VenueId] INT NOT NULL,
    [StartDateTimeUtc] DATETIME2(3) NOT NULL,
    [EndDateTimeUtc] DATETIME2(3) NOT NULL,
    [SetupStyle] VARCHAR(30) NULL,
    CONSTRAINT [PK_VenueBooking] PRIMARY KEY CLUSTERED ([VenueBookingId]),
    CONSTRAINT [UQ_VenueBooking_EventVenueStart] UNIQUE ([EventBookingId], [VenueId], [StartDateTimeUtc]),
    CONSTRAINT [FK_VenueBooking_EventBooking] FOREIGN KEY ([EventBookingId])
        REFERENCES [Events].[EventBooking] ([EventBookingId]),
    CONSTRAINT [FK_VenueBooking_Venue] FOREIGN KEY ([VenueId])
        REFERENCES [Resort].[Venue] ([VenueId]),
    CONSTRAINT [CK_VenueBooking_Dates] CHECK ([EndDateTimeUtc] > [StartDateTimeUtc]),
    CONSTRAINT [CK_VenueBooking_SetupStyle]
        CHECK ([SetupStyle] IS NULL OR [SetupStyle] IN ('Theater', 'Classroom', 'Banquet', 'Boardroom', 'Exhibition'))
);