SET NOCOUNT ON;

IF SCHEMA_ID(N'Resort') IS NULL
    THROW 51000, 'Smoke test failed: Resort schema is missing.', 1;

IF OBJECT_ID(N'Events.EventBooking', N'U') IS NULL
    THROW 51001, 'Smoke test failed: Events.EventBooking is missing.', 1;

IF OBJECT_ID(N'Events.EventOperationsSummary', N'V') IS NULL
    THROW 51002, 'Smoke test failed: Events.EventOperationsSummary is missing.', 1;

IF OBJECT_ID(N'Events.usp_CreateEventBooking', N'P') IS NULL
    THROW 51003, 'Smoke test failed: Events.usp_CreateEventBooking is missing.', 1;

IF OBJECT_ID(N'Events.trg_EventBooking_AuditStatus', N'TR') IS NULL
    THROW 51004, 'Smoke test failed: event status audit trigger is missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.security_policies
    WHERE [name] = N'PropertyAccessPolicy'
      AND [is_enabled] = 1
)
    THROW 51005, 'Smoke test failed: property access policy is not enabled.', 1;

IF (SELECT COUNT(*) FROM [Reference].[BookingStatus]) <> 6
    THROW 51006, 'Smoke test failed: booking status reference data is incomplete.', 1;

PRINT N'IntegratedResort.Database smoke test passed.';
