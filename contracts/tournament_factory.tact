import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";

import "./tournament.tact";

message Init {
    prizePool: Int;
}

contract TournamentFactory with Deployable {
    bank: Address;
    bankAmount: Int;

    tournaments: map<Address, Bool>; // tournament address contract -> is active
    tournamentsCount: Int;

    commission: Int = ton("0.1");

    init() {
        self.bank = newAddress(0, 0);
        self.bankAmount = 0;
        self.tournaments = emptyMap();
        self.tournamentsCount = 0;
    }

    receive() {}

    receive(msg: Init) {
        // TODO: Fix
        // require(msg.prizePool > self.commission, "You should have prize pool > 0.1");
        let prizePoolAfterCommission: Int = msg.prizePool - self.commission;

        let init: StateInit = initOf Tournament(sender(), prizePoolAfterCommission);
        let tournamentAddress: Address = contractAddress(init);

        send(SendParameters{
            to: tournamentAddress,
            body: CreateTournamentRequest{
                tournamentAddress: tournamentAddress,
            }.toCell(),
            value: self.commission, // pay for message and potential deployment
            mode: SendIgnoreErrors,
            code: init.code,  // if tournament is not deployed, also deploy it
            data: init.data,
        });
    }

    receive(msg: CreateTournamentResponse) {
        let isTournamentActive: Bool? = self.tournaments.get(msg.tournamentAddress);
        if (isTournamentActive == null || isTournamentActive == false) {
            self.tournaments.set(msg.tournamentAddress, true);
            self.tournamentsCount += 1;
        }
    }

    get fun bank(): Address {
        return self.bank;
    }

    get fun bankAmount(): Int {
        return self.bankAmount;
    }
    
    get fun tournaments(): map<Address, Bool> {
        return self.tournaments;
    }

    get fun tournamentsCount(): Int {
        return self.tournamentsCount;
    }
}
