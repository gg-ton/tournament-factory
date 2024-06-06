import "@stdlib/deploy";
import "@stdlib/ownable";

import "./player.tact";

struct TeamInfo {
    name: String;
    owner: Address;
    seqno: Int as uint64;
}

message VictoryRequest {
    player: Address;
}

message VictoryResponse {
    teamInfo: TeamInfo;
}

message AddTeamParticipantRequest {
    player: Address;
}

contract Team with Deployable {
    seqno: Int as uint64;
    owner: Address;
    
    name: String;
    victoryCount: Int as uint32;

    participants: map<Address, Bool>;
    participantCount: Int as uint32;

    init(teamInfo: TeamInfo) {
        self.seqno = teamInfo.seqno;
        self.owner = teamInfo.owner;
        self.name = teamInfo.name;

        self.victoryCount = 0;
        self.participants = emptyMap();
        self.participantCount = 0;
    }

    receive() {}

    receive(msg: AddTeamParticipantRequest) {
        let initPlayer: StateInit = initOf Player(msg.player);

        let isParticipantActive: Bool? = self.participants.get(contractAddress(initPlayer));
        if (isParticipantActive == null || isParticipantActive == false) {
            self.participants.set(contractAddress(initPlayer), true);
            self.participantCount += 1;
        }

        let initTeam: StateInit = initOf Team(TeamInfo{
            name: self.name,
            owner: self.owner,
            seqno: self.seqno,
        });

        send(SendParameters{
            to: contractAddress(initPlayer),
            body: SetTeamRequest{team: contractAddress(initTeam)}.toCell(),
            value: ton("0.1"),
            code: initPlayer.code,
            data: initPlayer.data
        });
    }

    receive(msg: VictoryRequest) {
        let init: StateInit = initOf Player(msg.player);

        let isParticipantActive: Bool? = self.participants.get(contractAddress(init));
        if (isParticipantActive == null || isParticipantActive == false) {
            self.victoryCount += 1;
        }

        self.reply(VictoryResponse{
            teamInfo: TeamInfo{
                name: self.name,
                owner: self.owner,
                seqno: self.seqno,
            }
        }.toCell());
    }

    get fun participants(): map<Address, Bool> {
        return self.participants;
    }

    get fun participantCount(): Int {
        return self.participantCount;
    }

    get fun seqno(): Int {
        return self.seqno;
    }

    get fun name(): String {
        return self.name;
    }

    get fun victoryCount(): Int {
        return self.victoryCount;
    }
}
