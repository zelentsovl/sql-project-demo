CREATE TABLE [Events].[ServiceCatalog]
(
    [ServiceId] INT IDENTITY(1, 1) NOT NULL,
    [PropertyId] INT NOT NULL,
    [ServiceCode] VARCHAR(30) NOT NULL,
    [ServiceName] NVARCHAR(150) NOT NULL,
    [ServiceType] VARCHAR(20) NOT NULL,
    [DefaultUnitPrice] DECIMAL(19, 4) NOT NULL,
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_ServiceCatalog_IsActive] DEFAULT (1),
    CONSTRAINT [PK_ServiceCatalog] PRIMARY KEY CLUSTERED ([ServiceId]),
    CONSTRAINT [UQ_ServiceCatalog_PropertyCode] UNIQUE ([PropertyId], [ServiceCode]),
    CONSTRAINT [FK_ServiceCatalog_Property] FOREIGN KEY ([PropertyId])
        REFERENCES [Resort].[Property] ([PropertyId]),
    CONSTRAINT [CK_ServiceCatalog_ServiceType]
        CHECK ([ServiceType] IN ('Catering', 'Technology', 'Staffing', 'Entertainment', 'Logistics')),
    CONSTRAINT [CK_ServiceCatalog_DefaultUnitPrice] CHECK ([DefaultUnitPrice] >= 0)
);