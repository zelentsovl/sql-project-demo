CREATE INDEX [IX_ResourceReading_Date]
ON [Sustainability].[ResourceReading] ([ReadingDateTimeUtc], [ResourceMeterId])
INCLUDE ([Quantity], [ReadingSource]);