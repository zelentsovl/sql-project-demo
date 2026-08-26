CREATE TABLE [Resort].[Venue]
(
    [VenueId] INT IDENTITY(1, 1) NOT NULL,
    [PropertyId] INT NOT NULL,
    [VenueCode] VARCHAR(30) NOT NULL,
    [VenueName] NVARCHAR(150) NOT NULL,
    [VenueType] VARCHAR(20) NOT NULL,
    [MaximumCapacity] INT NOT NULL,
    [AreaSquareFeet] DECIMAL(12, 2) NULL,
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_Venue_IsActive] DEFAULT (1),
    [RowVersion] ROWVERSION NOT NULL,
    [ValidFromUtc] DATETIME2(7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
        CONSTRAINT [DF_Venue_ValidFromUtc] DEFAULT (SYSUTCDATETIME()),
    [ValidToUtc] DATETIME2(7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
        CONSTRAINT [DF_Venue_ValidToUtc] DEFAULT ('9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME ([ValidFromUtc], [ValidToUtc]),
    CONSTRAINT [PK_Venue] PRIMARY KEY CLUSTERED ([VenueId]),
    CONSTRAINT [UQ_Venue_PropertyCode] UNIQUE ([PropertyId], [VenueCode]),
    CONSTRAINT [FK_Venue_Property] FOREIGN KEY ([PropertyId])
        REFERENCES [Resort].[Property] ([PropertyId]),
    CONSTRAINT [CK_Venue_VenueType]
        CHECK ([VenueType] IN ('Convention', 'Exhibition', 'Meeting', 'Arena', 'Theater', 'Outdoor')),
    CONSTRAINT [CK_Venue_MaximumCapacity] CHECK ([MaximumCapacity] > 0),
    CONSTRAINT [CK_Venue_AreaSquareFeet] CHECK ([AreaSquareFeet] IS NULL OR [AreaSquareFeet] > 0)
)
WITH
(
    SYSTEM_VERSIONING = ON
    (
        HISTORY_TABLE = [Audit].[VenueHistory],
        DATA_CONSISTENCY_CHECK = ON
    )
);