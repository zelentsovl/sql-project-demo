CREATE PROCEDURE [Sustainability].[usp_RecordResourceReading]
    @ResourceMeterId INT,
    @ReadingDateTimeUtc DATETIME2(3),
    @Quantity DECIMAL(19, 4),
    @ReadingSource VARCHAR(20) = 'Manual'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Quantity < 0
        THROW 50010, 'Resource quantity cannot be negative.', 1;

    MERGE [Sustainability].[ResourceReading] WITH (HOLDLOCK) AS target
    USING
    (
        SELECT
            @ResourceMeterId AS [ResourceMeterId],
            @ReadingDateTimeUtc AS [ReadingDateTimeUtc]
    ) AS source
        ON target.[ResourceMeterId] = source.[ResourceMeterId]
       AND target.[ReadingDateTimeUtc] = source.[ReadingDateTimeUtc]
    WHEN MATCHED THEN
        UPDATE SET
            [Quantity] = @Quantity,
            [ReadingSource] = @ReadingSource,
            [RecordedAtUtc] = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT ([ResourceMeterId], [ReadingDateTimeUtc], [Quantity], [ReadingSource])
        VALUES (@ResourceMeterId, @ReadingDateTimeUtc, @Quantity, @ReadingSource);
END;