CREATE ROLE [resort_reader];
GO

CREATE ROLE [event_coordinator];
GO

CREATE ROLE [sustainability_analyst];
GO

GRANT SELECT ON SCHEMA::[Reference] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Resort] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Events] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Sustainability] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Loyalty] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Finance] TO [resort_reader];
GO

GRANT SELECT ON SCHEMA::[Reference] TO [event_coordinator];
GO

GRANT SELECT ON SCHEMA::[Resort] TO [event_coordinator];
GO

GRANT SELECT ON SCHEMA::[Events] TO [event_coordinator];
GO

GRANT EXECUTE ON SCHEMA::[Events] TO [event_coordinator];
GO

GRANT UNMASK TO [event_coordinator];
GO

GRANT SELECT ON SCHEMA::[Finance] TO [event_coordinator];
GO

GRANT EXECUTE ON SCHEMA::[Finance] TO [event_coordinator];
GO

GRANT SELECT ON SCHEMA::[Resort] TO [sustainability_analyst];
GO

GRANT SELECT, INSERT, UPDATE ON SCHEMA::[Sustainability] TO [sustainability_analyst];
GO

GRANT EXECUTE ON SCHEMA::[Sustainability] TO [sustainability_analyst];