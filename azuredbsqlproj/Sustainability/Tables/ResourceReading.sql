CREATE TABLE [Sustainability].[ResourceReading]
(
    [ResourceReadingId] BIGINT IDENTITY(1, 1) NOT NULL,
    [ResourceMeterId] INT NOT NULL,
    [ReadingDateTimeUtc] DATETIME2(3) NOT NULL,
    [Quantity] DECIMAL(19, 4) NOT NULL,
    [ReadingSource] VARCHAR(20) NOT NULL
        CONSTRAINT [DF_ResourceReading_ReadingSource] DEFAULT ('Manual'),
    [RecordedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_ResourceReading_RecordedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_ResourceReading] PRIMARY KEY CLUSTERED ([ResourceReadingId]),
    CONSTRAINT [UQ_ResourceReading_MeterDate] UNIQUE ([ResourceMeterId], [ReadingDateTimeUtc]),
    CONSTRAINT [FK_ResourceReading_ResourceMeter] FOREIGN KEY ([ResourceMeterId])
        REFERENCES [Sustainability].[ResourceMeter] ([ResourceMeterId]),
    CONSTRAINT [CK_ResourceReading_Quantity] CHECK ([Quantity] >= 0),
    CONSTRAINT [CK_ResourceReading_Source]
        CHECK ([ReadingSource] IN ('Manual', 'IoT', 'Import', 'Estimate'))
);