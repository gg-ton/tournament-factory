import "@stdlib/deploy";
import "@stdlib/ownable";

message SetTeamRequest {
    team: Address;
}

contract Player with Deployable, Ownable {
    team: Address;
    owner: Address;

    init(owner: Address) {
        self.owner = owner;
        self.team = newAddress(0, 0);
    }

    receive() {}

    receive(msg: SetTeamRequest) {
        self.team = msg.team;
    }

    get fun team(): Address {
        return self.team;
    }
}
