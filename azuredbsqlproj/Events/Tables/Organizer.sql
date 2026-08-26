CREATE TABLE [Events].[Organizer]
(
    [OrganizerId] INT IDENTITY(1, 1) NOT NULL,
    [OrganizationName] NVARCHAR(200) NOT NULL,
    [ContactName] NVARCHAR(150) MASKED WITH (FUNCTION = 'partial(1,"XXXX",1)') NULL,
    [ContactEmail] NVARCHAR(320) MASKED WITH (FUNCTION = 'email()') NULL,
    [ContactPhone] NVARCHAR(40) MASKED WITH (FUNCTION = 'partial(0,"XXX-XXX-",4)') NULL,
    [CountryCode] CHAR(2) NULL,
    [CreatedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Organizer_CreatedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Organizer] PRIMARY KEY CLUSTERED ([OrganizerId])
);