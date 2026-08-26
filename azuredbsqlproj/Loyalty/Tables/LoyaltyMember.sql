CREATE TABLE [Loyalty].[LoyaltyMember]
(
    [LoyaltyMemberId] BIGINT IDENTITY(1, 1) NOT NULL,
    [MemberNumber] VARCHAR(30) NOT NULL,
    [GivenName] NVARCHAR(100) MASKED WITH (FUNCTION = 'partial(1,"XXXX",0)') NOT NULL,
    [FamilyName] NVARCHAR(100) MASKED WITH (FUNCTION = 'partial(1,"XXXX",0)') NOT NULL,
    [EmailAddress] NVARCHAR(320) MASKED WITH (FUNCTION = 'email()') NULL,
    [TierCode] VARCHAR(20) NOT NULL
        CONSTRAINT [DF_LoyaltyMember_TierCode] DEFAULT ('Member'),
    [HomeMarketCode] CHAR(2) NULL,
    [IsActive] BIT NOT NULL
        CONSTRAINT [DF_LoyaltyMember_IsActive] DEFAULT (1),
    [CreatedAtUtc] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_LoyaltyMember_CreatedAtUtc] DEFAULT (SYSUTCDATETIME()),
    [RowVersion] ROWVERSION NOT NULL,
    CONSTRAINT [PK_LoyaltyMember] PRIMARY KEY CLUSTERED ([LoyaltyMemberId]),
    CONSTRAINT [UQ_LoyaltyMember_MemberNumber] UNIQUE ([MemberNumber]),
    CONSTRAINT [CK_LoyaltyMember_TierCode]
        CHECK ([TierCode] IN ('Member', 'Preferred', 'Elite')),
    CONSTRAINT [CK_LoyaltyMember_HomeMarketCode]
        CHECK ([HomeMarketCode] IS NULL OR [HomeMarketCode] IN ('R1', 'R2', 'R3', 'R4', 'R5'))
);