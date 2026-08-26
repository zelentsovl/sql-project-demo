PRINT N'Applying reference data for $(EnvironmentName).';

MERGE [Reference].[BookingStatus] AS target
USING
(
    VALUES
        ('Planned', N'Planned', 1, 0),
        ('Contracted', N'Contracted', 2, 0),
        ('Confirmed', N'Confirmed', 3, 0),
        ('InProgress', N'In Progress', 4, 0),
        ('Completed', N'Completed', 5, 1),
        ('Cancelled', N'Cancelled', 6, 1)
) AS source ([BookingStatusCode], [DisplayName], [SortOrder], [IsTerminal])
    ON target.[BookingStatusCode] = source.[BookingStatusCode]
WHEN MATCHED THEN
    UPDATE SET
        [DisplayName] = source.[DisplayName],
        [SortOrder] = source.[SortOrder],
        [IsTerminal] = source.[IsTerminal]
WHEN NOT MATCHED THEN
    INSERT ([BookingStatusCode], [DisplayName], [SortOrder], [IsTerminal])
    VALUES (source.[BookingStatusCode], source.[DisplayName], source.[SortOrder], source.[IsTerminal]);

IF '$(SeedDemoData)' = 'True'
BEGIN
    PRINT N'Applying fictional resort demo data.';

    MERGE [Resort].[Property] AS target
    USING
    (
        VALUES
            ('RESORT-ALPHA', N'Demo Resort Alpha', 'R1', 'USD', N'UTC', 1),
            ('RESORT-BRAVO', N'Demo Resort Bravo', 'R1', 'USD', N'UTC', 1),
            ('RESORT-CHARLIE', N'Demo Resort Charlie', 'R1', 'USD', N'UTC', 1),
            ('RESORT-DELTA', N'Demo Resort Delta', 'R1', 'USD', N'UTC', 1),
            ('RESORT-ECHO', N'Demo Resort Echo', 'R1', 'USD', N'UTC', 1),
            ('RESORT-FOXTROT', N'Demo Resort Foxtrot', 'R2', 'EUR', N'UTC', 1)
    ) AS source ([PropertyCode], [PropertyName], [MarketCode], [CurrencyCode], [TimeZoneName], [IsActive])
        ON target.[PropertyCode] = source.[PropertyCode]
    WHEN MATCHED THEN
        UPDATE SET
            [PropertyName] = source.[PropertyName],
            [MarketCode] = source.[MarketCode],
            [CurrencyCode] = source.[CurrencyCode],
            [TimeZoneName] = source.[TimeZoneName],
            [IsActive] = source.[IsActive]
    WHEN NOT MATCHED THEN
        INSERT ([PropertyCode], [PropertyName], [MarketCode], [CurrencyCode], [TimeZoneName], [IsActive])
        VALUES (source.[PropertyCode], source.[PropertyName], source.[MarketCode], source.[CurrencyCode], source.[TimeZoneName], source.[IsActive]);

    DECLARE @ResortAlphaId INT =
        (SELECT [PropertyId] FROM [Resort].[Property] WHERE [PropertyCode] = 'RESORT-ALPHA');
    DECLARE @ResortFoxtrotId INT =
        (SELECT [PropertyId] FROM [Resort].[Property] WHERE [PropertyCode] = 'RESORT-FOXTROT');

    MERGE [Resort].[Venue] AS target
    USING
    (
        VALUES
            (@ResortAlphaId, 'CONVENTION-DEMO', N'Convention Hall - Demo', 'Convention', 5000, 250000.00, 1),
            (@ResortFoxtrotId, 'EXPO-DEMO', N'Expo Hall - Demo', 'Exhibition', 4000, 180000.00, 1)
    ) AS source ([PropertyId], [VenueCode], [VenueName], [VenueType], [MaximumCapacity], [AreaSquareFeet], [IsActive])
        ON target.[PropertyId] = source.[PropertyId]
       AND target.[VenueCode] = source.[VenueCode]
    WHEN MATCHED THEN
        UPDATE SET
            [VenueName] = source.[VenueName],
            [VenueType] = source.[VenueType],
            [MaximumCapacity] = source.[MaximumCapacity],
            [AreaSquareFeet] = source.[AreaSquareFeet],
            [IsActive] = source.[IsActive]
    WHEN NOT MATCHED THEN
        INSERT ([PropertyId], [VenueCode], [VenueName], [VenueType], [MaximumCapacity], [AreaSquareFeet], [IsActive])
        VALUES (source.[PropertyId], source.[VenueCode], source.[VenueName], source.[VenueType], source.[MaximumCapacity], source.[AreaSquareFeet], source.[IsActive]);

    MERGE [Events].[ServiceCatalog] AS target
    USING
    (
        VALUES
            (@ResortAlphaId, 'CATERING-PERSON', N'Event catering per attendee', 'Catering', 65.00, 1),
            (@ResortAlphaId, 'AV-DAY', N'Audio visual package per day', 'Technology', 2500.00, 1),
            (@ResortFoxtrotId, 'CATERING-PERSON', N'Event catering per attendee', 'Catering', 70.00, 1),
            (@ResortFoxtrotId, 'AV-DAY', N'Audio visual package per day', 'Technology', 3000.00, 1)
    ) AS source ([PropertyId], [ServiceCode], [ServiceName], [ServiceType], [DefaultUnitPrice], [IsActive])
        ON target.[PropertyId] = source.[PropertyId]
       AND target.[ServiceCode] = source.[ServiceCode]
    WHEN MATCHED THEN
        UPDATE SET
            [ServiceName] = source.[ServiceName],
            [ServiceType] = source.[ServiceType],
            [DefaultUnitPrice] = source.[DefaultUnitPrice],
            [IsActive] = source.[IsActive]
    WHEN NOT MATCHED THEN
        INSERT ([PropertyId], [ServiceCode], [ServiceName], [ServiceType], [DefaultUnitPrice], [IsActive])
        VALUES (source.[PropertyId], source.[ServiceCode], source.[ServiceName], source.[ServiceType], source.[DefaultUnitPrice], source.[IsActive]);
END;