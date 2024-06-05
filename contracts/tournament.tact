import "@stdlib/deploy";

struct GameInfo {
    name: String;
    genre: String;
}

struct TournamentInfo {
    prizePool: Int;
    gameInfo: GameInfo;
}

message CreateTournamentRequest {
    tournamentAddress: Address;
}

message CreateTournamentResponse {
    tournamentAddress: Address;
}

message StartTournamentResponse {
    tournamentAddress: Address;
}

message FinishTournamentRequest {
    winner: Address;
}

contract Tournament {
    owner: Address;

    prizePool: Int as coins;

    participants: map<Address, Bool>;
    participantCount: Int as uint16;

    sponsorFunds: map<Address, Int>;
    sponsorFundsAmount: Int as coins;

    init(owner: Address) {
        self.owner = owner;
    
        self.prizePool = 0;
        self.participants = emptyMap();
        self.participantCount = 0;
        self.sponsorFunds = emptyMap();
        self.sponsorFundsAmount = 0;
    }

    receive(msg: CreateTournamentRequest) {
        try {
            require(sender() == self.owner, "Only owner can create the tournament");
        } catch (e) {
            dump(e);
        }
        self.prizePool = context().value;
        
        self.reply(CreateTournamentResponse{tournamentAddress: msg.tournamentAddress}.toCell());
    }

    // receive("join") {
    //     try {
    //         require(sender() != self.owner, "Owner can't join the tournament");            
    //     } catch (e) {
    //         dump(e);
    //     }

    //     let isParticipantActive: Bool? = self.participants.get(msg.participant);
    //     if (isParticipantActive != null || isParticipantActive == false) {
    //         self.participants.set(msg.participant, true);
    //         self.participantCount += 1;
    //     }
    // }

    // receive("start") {
    //     try {
    //         require(self.participantCount > 0, "Can't start tournament without participants");
    //         require(sender() == self.owner, "Only owner can start the tournament");            
    //     } catch (e) {
    //         dump(e);
    //     }

    //     foreach (participantAddress, isParticipantActive in self.participants) {
    //         // if participant is not active throw error
    //         // 34 errors code: Action is invalid or not supported. Set during action phase if current action cannot be applied
    //         nativeThrowUnless(34, isParticipantActive);
    //     }

    //     self.reply(StartTournamentResponse{tournamentAddress: msg.tournamentAddress}.toCell());
    // }

    // receive(msg: FinishTournamentRequest) {
    //     try {
    //         require(sender() == self.owner, "Only owner can finish the tournament");            
    //     } catch (e) {
    //         dump(e);
    //     }

    //     let isParticipantActive: Bool? = self.participants.get(msg.participant);
    //     try {
    //         require(isParticipantActive != null, "This winner doesn't exsist");
    //         require(isParticipantActive == true, "Winner can't be inantive");
    //     } catch (e) {
    //         dump(e);
    //     }

    //     let winnerPrize: Int = self.sponsorFundsAmount + self.prizePool;

    //     // send prize to the winner
    //     send(SendParameters{
    //         to: msg.winner,
    //         body: CreateTournamentRequest{
    //             tournamentAddress: tournamentAddress,
    //         }.toCell(),
    //         value: winnerPrize, // pay for message and potential deployment
    //         mode: SendIgnoreErrors,
    //         code: init.code,  // if tournament is not deployed, also deploy it
    //         data: init.data,
    //     });
    // }

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