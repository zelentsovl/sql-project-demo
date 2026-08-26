CREATE VIEW [Events].[EventOperationsSummary]
AS
SELECT
    booking.[EventBookingId],
    booking.[EventNumber],
    property.[PropertyCode],
    property.[PropertyName],
    organizer.[OrganizationName],
    booking.[EventName],
    booking.[EventType],
    booking.[BookingStatusCode],
    booking.[StartDate],
    booking.[EndDate],
    booking.[DurationDays],
    booking.[ExpectedAttendees],
    booking.[CurrencyCode],
    [Events].[ufn_EventBookingTotal](booking.[EventBookingId]) AS [EstimatedTotal]
FROM [Events].[EventBooking] AS booking
INNER JOIN [Resort].[Property] AS property
    ON property.[PropertyId] = booking.[PropertyId]
INNER JOIN [Events].[Organizer] AS organizer
    ON organizer.[OrganizerId] = booking.[OrganizerId];