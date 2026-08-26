CREATE TABLE [Resort].[Property]
(
    [PropertyId] INT IDENTITY(1, 1) NOT NULL,
    [PropertyCode] VARCHAR(30) NOT NULL,
    [PropertyName] NVARCHAR(150) NOT NULL,
    [MarketCode] CHAR(2) NOT NULL,
    [CurrencyCode] CHAR(3) NOT NULL,
    [TimeZoneName] NVARCHAR(100) NOT NULL,
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_Property_IsActive] DEFAULT (1),
    [CreatedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Property_CreatedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Property] PRIMARY KEY CLUSTERED ([PropertyId]),
    CONSTRAINT [UQ_Property_PropertyCode] UNIQUE ([PropertyCode]),
    CONSTRAINT [CK_Property_MarketCode] CHECK ([MarketCode] IN ('R1', 'R2'))
);