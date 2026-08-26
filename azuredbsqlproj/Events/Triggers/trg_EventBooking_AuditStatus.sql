CREATE TRIGGER [Events].[trg_EventBooking_AuditStatus]
ON [Events].[EventBooking]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT [Audit].[BookingStatusChange]
    (
        [EventBookingId],
        [PreviousStatusCode],
        [NewStatusCode]
    )
    SELECT
        inserted.[EventBookingId],
        deleted.[BookingStatusCode],
        inserted.[BookingStatusCode]
    FROM inserted
    LEFT JOIN deleted
        ON deleted.[EventBookingId] = inserted.[EventBookingId]
    WHERE deleted.[EventBookingId] IS NULL
       OR deleted.[BookingStatusCode] <> inserted.[BookingStatusCode];
END;