import "@stdlib/deploy";

struct GameInfo {
    name: String;
    genre: String;
}

struct TournamentInfo {
    prizePool: Int;
    gameInfo: GameInfo;
}

message CreateTournament {
    tournamentAddress: Address;
}

message CreateTournamentResponse {
    tournamentAddress: Address;
}

message JoinTournament {
    participant: Address;
}

contract Tournament {
    owner: Address;

    prizePool: Int as coins;

    participants: map<Address, Bool>;
    participantCount: Int as uint16;

    sponsorFunds: map<Address, Int>;
    sponsorFundsAmount: Int as coins;

    init(owner: Address, prizePool: Int) {
        self.owner = owner;
        self.prizePool = prizePool;

        self.participants = emptyMap();
        self.participantCount = 0;
        self.sponsorFunds = emptyMap();
        self.sponsorFundsAmount = 0;
    }

    receive(msg: CreateTournament) {
        self.reply(CreateTournamentResponse{tournamentAddress: msg.tournamentAddress}.toCell());
    }

    receive(msg: JoinTournament) {
        let isParticipantActive: Bool = self.participants.get(msg.participant);
        if (isParticipantActive == false) {
            self.participants.set(msg.participant, true);
            self.participantCount += 1;
        }
    }

    get fun owner(): Address {
        return self.owner;
    }

    get fun prizePool(): Int {
        return self.prizePool;
    }

    get fun participants(): map<Address, Bool> {
        return self.participants;
    }

    get fun participantCount(): Int {
        return self.participantCount;
    }

    get fun sponsorFunds(): map<Address, Int> {
        require(self.owner == sender(), "You should to be an owner");
        return self.sponsorFunds;
    }

    get fun sponsorFundsAmount(): Int {
        require(self.owner == sender(), "You should to be an owner");
        return self.sponsorFundsAmount;
    }
}