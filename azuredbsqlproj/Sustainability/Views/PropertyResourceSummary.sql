CREATE VIEW [Sustainability].[PropertyResourceSummary]
AS
SELECT
    property.[PropertyId],
    property.[PropertyCode],
    property.[PropertyName],
    meter.[ResourceType],
    meter.[UnitOfMeasure],
    CONVERT(DATE, reading.[ReadingDateTimeUtc]) AS [ReadingDate],
    SUM(reading.[Quantity]) AS [TotalQuantity]
FROM [Sustainability].[ResourceReading] AS reading
INNER JOIN [Sustainability].[ResourceMeter] AS meter
    ON meter.[ResourceMeterId] = reading.[ResourceMeterId]
INNER JOIN [Resort].[Property] AS property
    ON property.[PropertyId] = meter.[PropertyId]
GROUP BY
    property.[PropertyId],
    property.[PropertyCode],
    property.[PropertyName],
    meter.[ResourceType],
    meter.[UnitOfMeasure],
    CONVERT(DATE, reading.[ReadingDateTimeUtc]);