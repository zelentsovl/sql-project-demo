CREATE TABLE [Sustainability].[ResourceMeter]
(
    [ResourceMeterId] INT IDENTITY(1, 1) NOT NULL,
    [PropertyId] INT NOT NULL,
    [VenueId] INT NULL,
    [MeterCode] VARCHAR(40) NOT NULL,
    [ResourceType] VARCHAR(20) NOT NULL,
    [UnitOfMeasure] VARCHAR(20) NOT NULL,
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_ResourceMeter_IsActive] DEFAULT (1),
    CONSTRAINT [PK_ResourceMeter] PRIMARY KEY CLUSTERED ([ResourceMeterId]),
    CONSTRAINT [UQ_ResourceMeter_PropertyCode] UNIQUE ([PropertyId], [MeterCode]),
    CONSTRAINT [FK_ResourceMeter_Property] FOREIGN KEY ([PropertyId])
        REFERENCES [Resort].[Property] ([PropertyId]),
    CONSTRAINT [FK_ResourceMeter_Venue] FOREIGN KEY ([VenueId])
        REFERENCES [Resort].[Venue] ([VenueId]),
    CONSTRAINT [CK_ResourceMeter_ResourceType]
        CHECK ([ResourceType] IN ('Energy', 'Water', 'Waste', 'Carbon')),
    CONSTRAINT [CK_ResourceMeter_UnitOfMeasure]
        CHECK ([UnitOfMeasure] IN ('kWh', 'MWh', 'Liter', 'CubicMeter', 'Kilogram', 'MetricTon', 'kgCO2e'))
);