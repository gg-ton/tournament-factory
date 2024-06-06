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
    prizePool: Int;
    maxParticipantCount: Int as uint16;
}

message JoinTournamentRequest {}

message StartTournamentRequest {}

message FinishTournamentRequest {
    winner: Address;
}

contract Tournament with Deployable {
    const minTonForStorage: Int = ton("0.01"); // enough for 1 KB of storage for 2.5 years
    const commission: Int = ton("0.01");

    owner: Address;

    prizePool: Int as coins;
    // TODO: remove address
    prizePoolAddress: Address = address("EQCD39VS5jcptHL8vMjEXrzGaRcCVYto7HUn4bpAOg8xqB2N");

    participants: map<Address, Bool>; // participant address -> is active
    participantCount: Int as uint16;
    maxParticipantCount: Int as uint16;

    sponsorFunds: map<Address, Int>;
    sponsorFundsAmount: Int as coins;

    isFinished: Bool;
    isStarted: Bool;

    init() {
        self.owner = sender();
    
        self.prizePool = 0;
        self.participants = emptyMap();
        self.participantCount = 0;
        self.maxParticipantCount = 0;
        self.sponsorFunds = emptyMap();
        self.sponsorFundsAmount = 0;
        self.isFinished = false;
        self.isStarted = false;
    }

    receive(msg: CreateTournamentRequest) {
        try {
            require(sender() == self.owner, "Only owner can create the tournament");
        } catch (e) {
            dump(e);
            nativeThrow(34);
        }

        let prizePoolAfterCommission: Int = msg.prizePool - self.commission - self.minTonForStorage;

        send(SendParameters{
            to:     self.prizePoolAddress,
            value: prizePoolAfterCommission, // pay for message and potential deployment
        });

        self.prizePool = prizePoolAfterCommission;
        self.maxParticipantCount = msg.maxParticipantCount;
    }

    receive(msg: JoinTournamentRequest) {
        try {
            require(self.participantCount+1 <= self.maxParticipantCount, "Tournament has max participants count");
        } catch (e) {
            nativeThrow(34);
        }

        let isParticipantActive: Bool? = self.participants.get(sender());
        if (isParticipantActive == null || isParticipantActive == false) {
            self.participants.set(sender(), true);
            self.participantCount += 1;
        }
    }

    receive(msg: StartTournamentRequest) {
        try {
            require(self.participantCount > 0, "Can't start tournament without participants");
            require(sender() == self.owner, "Only owner can start the tournament");
            require(self.isFinished == false, "Tournament already finished");
            require(self.isStarted == false, "Tournament already started");
        } catch (e) {
            dump(e);
            nativeThrow(34);
        }

        self.isStarted = true;
    }

    receive(msg: FinishTournamentRequest) {
        try {
            require(sender() == self.owner, "Only owner can finish the tournament");            
        } catch (e) {
            dump(e);
            nativeThrow(34);
        }

        let isParticipantActive: Bool? = self.participants.get(msg.winner);
        try {
            require(isParticipantActive != null, "This winner doesn't exsist");
            require(isParticipantActive == true, "Winner can't be inantive");
        } catch (e) {
            dump(e);
            nativeThrow(34);
        }

        let winnerPrize: Int = self.sponsorFundsAmount + self.prizePool;

        // send prize to the winner
        send(SendParameters{
            to: msg.winner,
            value: winnerPrize, // pay for message and potential deployment
        });

        self.isFinished = true;
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

    get fun maxParticipantCount(): Int {
        return self.maxParticipantCount;
    }

    get fun sponsorFunds(): map<Address, Int> {
        require(self.owner == sender(), "You should to be an owner");
        return self.sponsorFunds;
    }

    get fun sponsorFundsAmount(): Int {
        require(self.owner == sender(), "You should to be an owner");
        return self.sponsorFundsAmount;
    }

    get fun isFinished(): Bool {
        return self.isFinished;
    }

    get fun isStarted(): Bool {
        return self.isStarted;
    }
}