CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE teams (
    teamId UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teamName VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    conference VARCHAR(10) CHECK (conference IN ('East', 'West')),
    division VARCHAR(20) NOT NULL,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE players (
    playerId UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teamId UUID REFERENCES teams(teamId),
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    position VARCHAR(5) CHECK (position IN ('PG', 'SG', 'SF', 'PF', 'C')),
    height NUMERIC(3,2),
    weight INTEGER,
    overallRating INTEGER CHECK (overallRating BETWEEN 0 AND 99),
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE games (
    gameId UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    homeTeamId UUID REFERENCES teams(teamId),
    awayTeamId UUID REFERENCES teams(teamId),
    gameDate DATE NOT NULL,
    homeScore INTEGER,
    awayScore INTEGER,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playerStats (
    statId UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    playerId UUID REFERENCES players(playerId),
    gameId UUID REFERENCES games(gameId),
    points INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    rebounds INTEGER DEFAULT 0,
    steals INTEGER DEFAULT 0,
    blocks INTEGER DEFAULT 0,
    turnovers INTEGER DEFAULT 0,
    minutesPlayed INTEGER DEFAULT 0,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_players_team ON players(teamId);
CREATE INDEX idx_games_home_team ON games(homeTeamId);
CREATE INDEX idx_games_away_team ON games(awayTeamId);
CREATE INDEX idx_player_stats_player ON playerStats(playerId);
CREATE INDEX idx_player_stats_game ON playerStats(gameId);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_teams_timestamp
BEFORE UPDATE ON teams
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_players_timestamp
BEFORE UPDATE ON players
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_games_timestamp
BEFORE UPDATE ON games
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_player_stats_timestamp
BEFORE UPDATE ON playerStats
FOR EACH ROW EXECUTE FUNCTION update_timestamp();
