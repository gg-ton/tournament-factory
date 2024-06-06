import "@stdlib/deploy";

import "./tournament.tact";

struct GameInfo {
    name: String;
    genre: String;
}

contract Match with Deployable {
    tournamentSeqno: Int as uint64;

    gameInfo: GameInfo;

    init(tournamentSeqno: Int, gameInfo: GameInfo) {
        self.tournamentSeqno = tournamentSeqno;
        self.gameInfo = GameInfo{
            name: gameInfo.name,
            genre: gameInfo.genre,
        };
    }

    receive() {}
}
