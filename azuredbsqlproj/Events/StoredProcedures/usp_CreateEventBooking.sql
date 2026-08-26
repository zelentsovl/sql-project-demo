CREATE PROCEDURE [Events].[usp_CreateEventBooking]
    @PropertyId INT,
    @OrganizerId INT,
    @EventName NVARCHAR(200),
    @EventType VARCHAR(20),
    @StartDate DATE,
    @EndDate DATE,
    @ExpectedAttendees INT,
    @VenueFee DECIMAL(19, 4),
    @CreatedBy NVARCHAR(256),
    @Services [Events].[BookingServiceLineType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EndDate < @StartDate
        THROW 50001, 'The event end date cannot precede its start date.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [Resort].[Property]
        WHERE [PropertyId] = @PropertyId
          AND [IsActive] = 1
    )
        THROW 50002, 'The selected property is missing or inactive.', 1;

    BEGIN TRANSACTION;

    DECLARE @EventBookingId BIGINT;
    DECLARE @CurrencyCode CHAR(3);

    SELECT @CurrencyCode = [CurrencyCode]
    FROM [Resort].[Property]
    WHERE [PropertyId] = @PropertyId;

    INSERT [Events].[EventBooking]
    (
        [PropertyId],
        [OrganizerId],
        [EventName],
        [EventType],
        [StartDate],
        [EndDate],
        [ExpectedAttendees],
        [CurrencyCode],
        [VenueFee],
        [CreatedBy]
    )
    VALUES
    (
        @PropertyId,
        @OrganizerId,
        @EventName,
        @EventType,
        @StartDate,
        @EndDate,
        @ExpectedAttendees,
        @CurrencyCode,
        @VenueFee,
        @CreatedBy
    );

    SET @EventBookingId = SCOPE_IDENTITY();

    INSERT [Events].[BookingService]
    (
        [EventBookingId],
        [ServiceId],
        [Quantity],
        [UnitPrice],
        [DiscountAmount]
    )
    SELECT
        @EventBookingId,
        serviceLine.[ServiceId],
        serviceLine.[Quantity],
        catalog.[DefaultUnitPrice],
        COALESCE(serviceLine.[DiscountAmount], 0)
    FROM @Services AS serviceLine
    INNER JOIN [Events].[ServiceCatalog] AS catalog
        ON catalog.[ServiceId] = serviceLine.[ServiceId]
       AND catalog.[PropertyId] = @PropertyId
       AND catalog.[IsActive] = 1;

    IF @@ROWCOUNT <> (SELECT COUNT(*) FROM @Services)
        THROW 50003, 'One or more services are unavailable at the selected property.', 1;

    COMMIT TRANSACTION;

    SELECT
        booking.[EventBookingId],
        booking.[EventNumber],
        booking.[BookingStatusCode],
        [Events].[ufn_EventBookingTotal](booking.[EventBookingId]) AS [EstimatedTotal]
    FROM [Events].[EventBooking] AS booking
    WHERE booking.[EventBookingId] = @EventBookingId;
END;