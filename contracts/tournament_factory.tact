import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";

import "./tournament.tact";

message CreateTournamentRequest {
    owner: Address;
    prizePool: Int as coins;
}

contract TournamentFactory with Deployable {
    bank: Address;
    bankAmount: Int as coins;

    tournaments: map<Address, Bool>; // tournament address contract -> is finished
    tournamentsCount: Int;

    init() {
        self.bank = newAddress(0, 0);
        self.bankAmount = 0;
        self.tournaments = emptyMap();
        self.tournamentsCount = 0;
    }

    receive(msg: CreateTournamentRequest) {   
        let init: StateInit = initOf Tournament(msg.owner, msg.prizePool);
        let tournamentAddress: Address = contractAddress(init);

        send(SendParameters{
            to: tournamentAddress,
            body: CreateTournament{
                tournamentAddress: tournamentAddress,
            }.toCell(),
            value: ton("0.1"), // pay for message and potential deployment
            mode: SendRemainingValue + SendIgnoreErrors,
            code: init.code,  // if tournament is not deployed, also deploy it
            data: init.data,
        });

        // TODO: Update tournaments state at the receive(msg: CreateTournamentResponse)
        self.tournaments.set(tournamentAddress, true);
        self.tournamentsCount += 1;
    }

    receive(msg: CreateTournamentResponse) {
        let isTournamentActive: Bool? = self.tournaments.get(msg.tournamentAddress);
        if (isTournamentActive == null) {
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
