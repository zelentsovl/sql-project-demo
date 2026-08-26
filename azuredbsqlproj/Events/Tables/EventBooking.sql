CREATE TABLE [Events].[EventBooking]
(
    [EventBookingId] BIGINT IDENTITY(1, 1) NOT NULL,
    [EventSequence] BIGINT NOT NULL
        CONSTRAINT [DF_EventBooking_EventSequence] DEFAULT (NEXT VALUE FOR [Events].[EventNumberSequence]),
    [EventNumber] AS ('EVT-' + CONVERT(VARCHAR(20), [EventSequence])) PERSISTED,
    [PropertyId] INT NOT NULL,
    [OrganizerId] INT NOT NULL,
    [EventName] NVARCHAR(200) NOT NULL,
    [EventType] VARCHAR(20) NOT NULL,
    [BookingStatusCode] VARCHAR(20) NOT NULL
        CONSTRAINT [DF_EventBooking_BookingStatusCode] DEFAULT ('Planned'),
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [DurationDays] AS (DATEDIFF(DAY, [StartDate], [EndDate]) + 1) PERSISTED,
    [ExpectedAttendees] INT NOT NULL,
    [CurrencyCode] CHAR(3) NOT NULL,
    [VenueFee] DECIMAL(19, 4) NOT NULL
        CONSTRAINT [DF_EventBooking_VenueFee] DEFAULT (0),
    [EventConfiguration] NVARCHAR(MAX) NULL,
    [Notes] NVARCHAR(1000) NULL,
    [CreatedBy] NVARCHAR(256) NOT NULL
        CONSTRAINT [DF_EventBooking_CreatedBy] DEFAULT (ORIGINAL_LOGIN()),
    [ModifiedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_EventBooking_ModifiedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_EventBooking] PRIMARY KEY CLUSTERED ([EventBookingId]),
    CONSTRAINT [UQ_EventBooking_EventSequence] UNIQUE ([EventSequence]),
    CONSTRAINT [FK_EventBooking_Property] FOREIGN KEY ([PropertyId])
        REFERENCES [Resort].[Property] ([PropertyId]),
    CONSTRAINT [FK_EventBooking_Organizer] FOREIGN KEY ([OrganizerId])
        REFERENCES [Events].[Organizer] ([OrganizerId]),
    CONSTRAINT [FK_EventBooking_BookingStatus] FOREIGN KEY ([BookingStatusCode])
        REFERENCES [Reference].[BookingStatus] ([BookingStatusCode]),
    CONSTRAINT [CK_EventBooking_EventType]
        CHECK ([EventType] IN ('Convention', 'Exhibition', 'Meeting', 'Incentive', 'Entertainment', 'Sporting')),
    CONSTRAINT [CK_EventBooking_Dates] CHECK ([EndDate] >= [StartDate]),
    CONSTRAINT [CK_EventBooking_Attendees] CHECK ([ExpectedAttendees] > 0),
    CONSTRAINT [CK_EventBooking_VenueFee] CHECK ([VenueFee] >= 0),
    CONSTRAINT [CK_EventBooking_EventConfiguration]
        CHECK ([EventConfiguration] IS NULL OR ISJSON([EventConfiguration]) = 1)
);