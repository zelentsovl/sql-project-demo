CREATE INDEX [IX_EventBooking_PropertyDates]
ON [Events].[EventBooking] ([PropertyId], [StartDate], [EndDate])
INCLUDE ([EventNumber], [EventName], [BookingStatusCode], [ExpectedAttendees]);