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

        tournamentFactory = blockchain.openContract(await TournamentFactory.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await tournamentFactory.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
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

    it('should increment counter', async () => {
        const increaseTimes = 3;
        for (let i = 0; i < increaseTimes; i++) {
            console.log(`increase ${i + 1}/${increaseTimes}`);

            const increaser = await blockchain.treasury('increaser' + i);

            const counterBefore = await tournamentFactory.getCounter();

            console.log('counter before increasing', counterBefore);

            const increaseBy = BigInt(Math.floor(Math.random() * 100));

            console.log('increasing by', increaseBy);

            const increaseResult = await tournamentFactory.send(
                increaser.getSender(),
                {
                    value: toNano('0.05'),
                },
                {
                    $$type: 'Add',
                    queryId: 0n,
                    amount: increaseBy,
                }
            );

            expect(increaseResult.transactions).toHaveTransaction({
                from: increaser.address,
                to:   tournamentFactory.address,
                success: true,
            });

            const counterAfter = await tournamentFactory.getCounter();

            console.log('counter after increasing', counterAfter);

            expect(counterAfter).toBe(counterBefore + increaseBy);
        }
    })

    it('should create tournament', async () => {
        const owner = await blockchain.treasury('owner');

        const tournamentsCountBefore = await tournamentFactory.getTournamentsCount();
        const tournamentsBefore = await tournamentFactory.getTournaments();

        console.log('tournaments count', tournamentsCountBefore);
        console.log('tournaments before creating', tournamentsBefore);

        const tournamentResult = await tournamentFactory.send(
            owner.getSender(),
            {
                value: toNano('1.65'),
            },
            {
                $$type: 'CreateTournament',
                queryId: 0n,
                owner: owner.address,
                tournamentInfo: {
                    $$type: 'TournamentInfo',
                    id: 0n,
                    game: {
                        $$type: 'GameInfo',
                        name: 'csgo',
                        genre: 'shooter',
                        description: null
                    },
                    prizePool: 10n
                },
            }
        );

        expect(tournamentResult.transactions).toHaveTransaction({
            from:    tournamentFactory.address,
            success: true,
        });

        const tournamentAfter = await tournamentFactory.getTournaments();
        const tournamentsCountAfter = await tournamentFactory.getTournamentsCount();

        console.log('tournaments count', tournamentsCountAfter);
        console.log('tournaments after creating', tournamentAfter);

        expect(tournamentsCountAfter).toBe(tournamentsCountBefore + 1n);
    })
});
