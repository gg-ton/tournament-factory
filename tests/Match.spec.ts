import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Match } from '../wrappers/Match';
import { Tournament } from '../wrappers/Tournament';
import '@ton/test-utils';

describe('Match', () => {
    const tournamentSeqno = 0n;

    let blockchain: Blockchain;
    let matchContract: SandboxContract<Match>;
    let tournamentContract: SandboxContract<Tournament>;
    let owner: SandboxContract<TreasuryContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        owner = await blockchain.treasury('owner');

        tournamentContract = blockchain.openContract(await Tournament.fromInit(tournamentSeqno));

        const deployResultTournament = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResultTournament.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            deploy: true,
            success: true,
        });

        matchContract = blockchain.openContract(await Match.fromInit(tournamentSeqno, {
            $$type: "GameInfo",
            name: "csgo",
            genre: "shooter"
        }));

        const deployResult = await matchContract.send(
            owner.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: owner.address,
            to: matchContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and match are ready to use
    });
});
