import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { TournamentFactory } from '../wrappers/TournamentFactory';
import '@ton/test-utils';

describe('TournamentFactory', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let tournamentFactory: SandboxContract<TournamentFactory>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');

        tournamentFactory = blockchain.openContract(await TournamentFactory.fromInit());

        const deployResultTournamentFactory = await tournamentFactory.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResultTournamentFactory.transactions).toHaveTransaction({
            from: deployer.address,
            to: tournamentFactory.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and tournamentFactory are ready to use
    });

    it('should create tournament', async () => {
        const owner = await blockchain.treasury('owner');

        const tournamentsCountBefore = await tournamentFactory.getTournamentsCount();
        const tournamentsBefore = await tournamentFactory.getTournaments();

        console.log('tournaments count', tournamentsCountBefore);
        console.log('tournaments before creating', tournamentsBefore);

        const tournamentResult = await tournamentFactory.send(
            owner.getSender(),
            {
                value: toNano('0.65'),
            },
            {
                $$type: "CreateTournamentRequest",
                owner: owner.address,
                prizePool: 10n,
            },
        );

        expect(tournamentResult.transactions).toHaveTransaction({
            from:    owner.address,
            to:      tournamentFactory.address,
            success: true,
        });

        const tournamentAfter = await tournamentFactory.getTournaments();
        const tournamentsCountAfter = await tournamentFactory.getTournamentsCount();

        console.log('tournaments count', tournamentsCountAfter);
        console.log('tournaments after creating', tournamentAfter);

        expect(tournamentsCountAfter).toBe(tournamentsCountBefore + 1n);
    })
});
