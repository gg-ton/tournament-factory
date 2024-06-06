import "@stdlib/deploy";
import "@stdlib/ownable";

import "./player.tact";
import "./team.tact";

message CreateTournamentRequest {
    prizePool: Int;
    maxParticipantCount: Int as uint16;
}

message JoinTournamentRequest {}

message StartTournamentRequest {}

message FinishTournamentRequest {
    winner: Address;
}

contract Tournament with Deployable, Ownable {
    const minTonForStorage: Int = ton("0.01"); // enough for 1 KB of storage for 2.5 years
    const commission: Int = ton("0.01");

    owner: Address;
    seqno: Int as uint64;

    prizePool: Int as coins;
    prizePoolAddress: Address = address("kQD_KopE-zqVkrHoA9A-CGt81fJcNQsGYW9MiYP8xmfIT5Yw");

    participants: map<Address, Bool>; // participant address -> is active
    participantCount: Int as uint16;
    maxParticipantCount: Int as uint16;

    sponsorFunds: map<Address, Int>;
    sponsorFundsAmount: Int as coins;

    isFinished: Bool;
    isStarted: Bool;

    init(seqno: Int) {
        self.seqno = seqno;
        self.owner = sender();
    
        self.prizePool = 0;
        self.participantCount = 0;
        self.maxParticipantCount = 0;
        self.sponsorFundsAmount = 0;
        self.sponsorFunds = emptyMap();
        self.participants = emptyMap();

        self.isFinished = false;
        self.isStarted = false;
    }

    receive() {}

    receive(msg: CreateTournamentRequest) {
        self.requireOwner();

        let prizePoolAfterCommission: Int = msg.prizePool - self.commission - self.minTonForStorage;

        send(SendParameters{
            to: self.prizePoolAddress,
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

        let init: StateInit = initOf Player(sender());

        let isParticipantActive: Bool? = self.participants.get(contractAddress(init));
        if (isParticipantActive == null || isParticipantActive == false) {
            self.participants.set(contractAddress(init), true);
            self.participantCount += 1;
        }
    }

    receive(msg: StartTournamentRequest) {
        self.requireOwner();
        
        try {
            require(self.participantCount > 0, "Can't start tournament without participants");
            require(self.isFinished == false, "Tournament already finished");
            require(self.isStarted == false, "Tournament already started");
        } catch (e) {
            nativeThrow(34);
        }

        self.isStarted = true;
    }

    receive(msg: FinishTournamentRequest) {
        self.requireOwner();

        try {
            require(self.isFinished == false, "Tournament already finished");
        } catch (e) {
            nativeThrow(34);
        }

        let init: StateInit = initOf Player(msg.winner);

        let isParticipantActive: Bool? = self.participants.get(contractAddress(init));
        try {
            require(isParticipantActive != null, "This winner doesn't exsist");
            require(isParticipantActive == true, "Winner can't be inantive");
        } catch (e) {
            dump(e);
            nativeThrow(34);
        }

        send(SendParameters{
            to: contractAddress(init),
            body: VictoryRequest{ player: msg.winner }.toCell(),
            value: ton("0.1"),
            code: init.code,
            data: init.data
        });

        let winnerPrize: Int = self.sponsorFundsAmount + self.prizePool;

        // send prize to the winner
        send(SendParameters{
            to:    msg.winner,
            value: winnerPrize, // pay for message and potential deployment
        });

        self.isFinished = true;
        self.participants = emptyMap();
    }

    get fun seqno(): Int {
        return self.seqno;
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
        self.requireOwner();
        return self.sponsorFunds;
    }

    get fun sponsorFundsAmount(): Int {
        self.requireOwner();
        return self.sponsorFundsAmount;
    }

    get fun isFinished(): Bool {
        return self.isFinished;
    }

    get fun isStarted(): Bool {
        return self.isStarted;
    }
}