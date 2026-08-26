CREATE SECURITY POLICY [Security].[PropertyAccessPolicy]
ADD FILTER PREDICATE [Security].[fn_PropertyAccessPredicate]([PropertyId])
    ON [Events].[EventBooking],
ADD BLOCK PREDICATE [Security].[fn_PropertyAccessPredicate]([PropertyId])
    ON [Events].[EventBooking] AFTER INSERT,
ADD BLOCK PREDICATE [Security].[fn_PropertyAccessPredicate]([PropertyId])
    ON [Events].[EventBooking] AFTER UPDATE,
ADD FILTER PREDICATE [Security].[fn_PropertyAccessPredicate]([PropertyId])
    ON [Sustainability].[ResourceMeter]
WITH (STATE = ON);