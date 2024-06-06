import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Tournament } from '../wrappers/Tournament';
import '@ton/test-utils';

describe('Tournament', () => {
    let blockchain: Blockchain;
    let owner: SandboxContract<TreasuryContract>;
    let tournamentContract: SandboxContract<Tournament>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        owner = await blockchain.treasury('owner');

        tournamentContract = blockchain.openContract(await Tournament.fromInit());

        const deployResultTournament = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('0.55'),
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
    });

    it('should create tournament', async () => {
        const maxParticipantCount = 2n;

        const tournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('2.55'),
            },
            {
                $$type: "CreateTournamentRequest",
                prizePool: toNano("1.0"),
                maxParticipantCount: maxParticipantCount
            },
        );

        expect(tournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const maxParticipantCountResult = await tournamentContract.getMaxParticipantCount();

        expect(maxParticipantCount).toBe(maxParticipantCountResult);
    })

    it('should join participant to the tournament', async () => {
        const maxParticipantCount = 2n;

        const tournamentCreateTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('2.55'),
            },
            {
                $$type: "CreateTournamentRequest",
                prizePool: toNano("1.0"),
                maxParticipantCount: maxParticipantCount
            },
        );

        expect(tournamentCreateTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const participant = await blockchain.treasury('participant');

        const tournamentResult = await tournamentContract.send(
            participant.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(tournamentResult.transactions).toHaveTransaction({
            from: participant.address,
            to: tournamentContract.address,
            success: true,
        });

        const participantCount = await tournamentContract.getParticipantCount();
        
        expect(participantCount).toBe(1n);
    })

    it('should not join participant to the tournament, max participants error', async () => {
        const maxParticipantCount = 1n;

        const tournamentCreateTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('2.55'),
            },
            {
                $$type: "CreateTournamentRequest",
                prizePool: toNano("1.0"),
                maxParticipantCount: maxParticipantCount
            },
        );

        expect(tournamentCreateTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const participant1 = await blockchain.treasury('participant1');
        const participant2 = await blockchain.treasury('participant2');

        const tournamentResult1 = await tournamentContract.send(
            participant1.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(tournamentResult1.transactions).toHaveTransaction({
            from: participant1.address,
            to: tournamentContract.address,
            success: true,
        });

        const tournamentResult2 = await tournamentContract.send(
            participant2.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(tournamentResult2.transactions).toHaveTransaction({
            from: participant2.address,
            to: tournamentContract.address,
            success: false,
        });
    })

    it('should start tournament', async () => {
        const maxParticipantCount = 2n;

        const createTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('2.55'),
            },
            {
                $$type: "CreateTournamentRequest",
                prizePool: toNano("1.0"),
                maxParticipantCount: maxParticipantCount
            },
        );

        expect(createTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const participant1 = await blockchain.treasury('participant1');
        const participant2 = await blockchain.treasury('participant2');

        const joinTournamentResult1 = await tournamentContract.send(
            participant1.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(joinTournamentResult1.transactions).toHaveTransaction({
            from: participant1.address,
            to: tournamentContract.address,
            success: true,
        });

        const joinTournamentResult2 = await tournamentContract.send(
            participant2.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(joinTournamentResult2.transactions).toHaveTransaction({
            from: participant2.address,
            to: tournamentContract.address,
            success: true,
        });

        const startTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "StartTournamentRequest",
            },
        );

        expect(startTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const isStarted = await tournamentContract.getIsStarted();

        expect(isStarted).toBe(true);
    })

    it('should finish tournament', async () => {
        const maxParticipantCount = 2n;

        const createTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('2.55'),
            },
            {
                $$type: "CreateTournamentRequest",
                prizePool: toNano("1.0"),
                maxParticipantCount: maxParticipantCount
            },
        );

        expect(createTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const participant1 = await blockchain.treasury('participant1');
        const participant2 = await blockchain.treasury('participant2');

        const joinTournamentResult1 = await tournamentContract.send(
            participant1.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(joinTournamentResult1.transactions).toHaveTransaction({
            from: participant1.address,
            to: tournamentContract.address,
            success: true,
        });

        const joinTournamentResult2 = await tournamentContract.send(
            participant2.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "JoinTournamentRequest",
            },
        );

        expect(joinTournamentResult2.transactions).toHaveTransaction({
            from: participant2.address,
            to: tournamentContract.address,
            success: true,
        });

        const startTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "StartTournamentRequest",
            },
        );

        expect(startTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });

        const finishTournamentResult = await tournamentContract.send(
            owner.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: "FinishTournamentRequest",
                winner: participant2.address,
            },
        );

        expect(finishTournamentResult.transactions).toHaveTransaction({
            from: owner.address,
            to: tournamentContract.address,
            success: true,
        });


        const isFinished = await tournamentContract.getIsFinished();

        expect(isFinished).toBe(true);
    })
});
