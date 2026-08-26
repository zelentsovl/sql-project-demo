CREATE INDEX [IX_Venue_ActiveProperty]
ON [Resort].[Venue] ([PropertyId], [VenueType])
INCLUDE ([VenueName], [MaximumCapacity], [AreaSquareFeet])
WHERE [IsActive] = 1;