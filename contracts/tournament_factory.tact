import "@stdlib/deploy";
import "@stdlib/ownable";

struct GameInfo {
    name: String;
    genre: String;
    description: String?;
}

struct TournamentInfo {
    id: Int as uint64;
    game: GameInfo;
    prizePool: Int;
}

struct Tournament {
    participants: map<Address, Bool>;
    participantCount: Int;
    info: TournamentInfo;
}

message CreateTournament {
    queryId: Int as uint64;
    owner: Address;
    tournamentInfo: TournamentInfo;
}

message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}

contract TournamentFactory with Deployable {
    owner: Address;
    
    tournaments: map<Int as uint64, Tournament>; // id -> tournament
    tournamentsCount: Int;

    counter: Int;

    init() {
        self.tournaments = emptyMap();
        self.tournamentsCount = 0;
        self.counter = 0;
        self.owner = newAddress(0, 0);
    }

    receive(msg: Add) {
        self.counter += msg.amount;
    }

    receive(msg: CreateTournament) {
        let existedTournament: Tournament? = self.tournaments.get(msg.tournamentInfo.id);
        require(existedTournament != null, "Tornament already exists");

        self.owner = sender();
        
        let newTournament: Tournament = Tournament{
            participants: emptyMap(),
            participantCount: 0,
            info: TournamentInfo{
                id: msg.tournamentInfo.id,
                prizePool: msg.tournamentInfo.prizePool,
                game: GameInfo{
                    name: msg.tournamentInfo.game.name,
                    genre: msg.tournamentInfo.game.genre,
                    description: msg.tournamentInfo.game.description,
                },
            },
        };

        self.tournaments.set(msg.tournamentInfo.id, newTournament);
        self.tournamentsCount += 1;
    }
    
    get fun tournaments(): map<Int as uint64, Tournament> {
        return self.tournaments;
    }

    get fun tournamentsCount(): Int {
        return self.tournamentsCount;
    }

    get fun owner(): Address {
        return self.owner;
    }

    get fun counter(): Int {
        return self.counter;
    }
}
