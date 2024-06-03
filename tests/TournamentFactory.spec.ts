import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { TournamentFactory } from '../wrappers/TournamentFactory';
import { Tournament } from '../wrappers/Tournament';
import '@ton/test-utils';

describe('TournamentFactory', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let tournamentFactoryContract: SandboxContract<TournamentFactory>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');

        tournamentFactoryContract = blockchain.openContract(await TournamentFactory.fromInit());

        const deployResultTournamentFactory = await tournamentFactoryContract.send(
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
            to: tournamentFactoryContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and tournamentFactory are ready to use
    });

    it('should create tournament', async () => {
        const tournamentsCountBefore = await tournamentFactoryContract.getTournamentsCount();
        const tournamentsBefore = await tournamentFactoryContract.getTournaments();

        console.log('tournaments count', tournamentsCountBefore);
        console.log('tournaments before creating', tournamentsBefore);

        const tournamentFactoryResult = await tournamentFactoryContract.send(
            deployer.getSender(),
            {
                value: toNano('0.65'),
            },
            {
                $$type: "Init",
                prizePool: 10n,
            },
        );

        expect(tournamentFactoryResult.transactions).toHaveTransaction({
            from:    deployer.address,
            to:      tournamentFactoryContract.address,
            success: true,
        });

        const tournamentsCountAfter = await tournamentFactoryContract.getTournamentsCount();
        const tournamentsAfter = await tournamentFactoryContract.getTournaments()

        console.log('tournaments count', tournamentsCountAfter);
        console.log('tournaments', tournamentsAfter);

        expect(tournamentsCountAfter).toBe(tournamentsCountBefore + 1n);
    })
});
