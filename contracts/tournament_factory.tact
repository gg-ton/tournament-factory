import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";

import "./tournament.tact";

message Init {
    prizePool: Int;
}

contract TournamentFactory with Deployable {
    const minTonForStorage: Int = ton("0.01"); // enough for 1 KB of storage for 2.5 years
    const commission: Int = ton("0.1");

    bank: Address;

    tournaments: map<Address, Bool>; // tournament address contract -> is active
    tournamentsCount: Int;
    activeTournamentCount: Int;

    init(bank: Address) {
        self.bank = bank;

        self.tournaments = emptyMap();
        self.tournamentsCount = 0;
        self.activeTournamentCount = 0;
    }

    receive() {}

    receive(msg: Init) {
        require(msg.prizePool > self.commission, "You should have prize pool > 0.1");

        let init: StateInit = initOf Tournament(sender());
        let tournamentAddress: Address = contractAddress(init);

        let prizePoolAfterCommission: Int = msg.prizePool - self.commission - self.minTonForStorage;

        send(SendParameters{
            to: tournamentAddress,
            body: CreateTournamentRequest{
                tournamentAddress: tournamentAddress,
            }.toCell(),
            value: prizePoolAfterCommission, // pay for message and potential deployment
            code: init.code,  // if tournament is not deployed, also deploy it
            data: init.data,
        });
    }

    receive(msg: CreateTournamentResponse) {
        let isTournamentActive: Bool? = self.tournaments.get(msg.tournamentAddress);
        if (isTournamentActive == null) {
            self.tournaments.set(msg.tournamentAddress, false);
            self.tournamentsCount += 1;
        }

        send(SendParameters{
            to: self.bank,
            bounce: true,
            value: self.commission,
            mode: SendRemainingValue + SendIgnoreErrors
        });
    }

    // receive(msg: StartTournamentResponse) {
    //     let isTournamentActive: Bool? = self.tournaments.get(msg.tournamentAddress);
    //     if (isTournamentActive != null || isTournamentActive == false) {
    //         self.tournaments.set(msg.tournamentAddress, true);
    //         self.activeTournamentCount += 1;
    //     }
    // }

    get fun bank(): Address {
        return self.bank;
    }
    
    get fun tournaments(): map<Address, Bool> {
        return self.tournaments;
    }

    get fun tournamentsCount(): Int {
        return self.tournamentsCount;
    }

    get fun activeTournamentCount(): Int {
        return self.activeTournamentCount;
    }
}
