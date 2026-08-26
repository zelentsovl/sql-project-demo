CREATE FUNCTION [Events].[ufn_EventBookingTotal]
(
    @EventBookingId BIGINT
)
RETURNS DECIMAL(19, 4)
AS
BEGIN
    DECLARE @Total DECIMAL(19, 4);

    SELECT @Total =
        booking.[VenueFee]
        + COALESCE(serviceTotals.[ServiceTotal], 0)
        + COALESCE(roomTotals.[RoomTotal], 0)
    FROM [Events].[EventBooking] AS booking
    OUTER APPLY
    (
        SELECT SUM(service.[LineTotal]) AS [ServiceTotal]
        FROM [Events].[BookingService] AS service
        WHERE service.[EventBookingId] = booking.[EventBookingId]
    ) AS serviceTotals
    OUTER APPLY
    (
        SELECT SUM(room.[EstimatedTotal]) AS [RoomTotal]
        FROM [Events].[RoomBlock] AS room
        WHERE room.[EventBookingId] = booking.[EventBookingId]
    ) AS roomTotals
    WHERE booking.[EventBookingId] = @EventBookingId;

    RETURN COALESCE(@Total, 0);
END;