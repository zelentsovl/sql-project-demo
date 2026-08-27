CREATE TABLE [Reference].[EventCategory]
(
    [EventCategoryCode] VARCHAR(20) NOT NULL,
    [DisplayName]       NVARCHAR(60) NOT NULL,
    [SortOrder]         TINYINT NOT NULL,
    [IsActive]          BIT NOT NULL
        CONSTRAINT [DF_EventCategory_IsActive] DEFAULT (1),
    CONSTRAINT [PK_EventCategory] PRIMARY KEY CLUSTERED ([EventCategoryCode]),
    CONSTRAINT [UQ_EventCategory_SortOrder] UNIQUE ([SortOrder])
);