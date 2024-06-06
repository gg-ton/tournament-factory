import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Team } from '../wrappers/Team';
import { Player } from '../wrappers/Player';
import '@ton/test-utils';

describe('Team', () => {
    let blockchain: Blockchain;
    let teamContract: SandboxContract<Team>;
    let playerContract: SandboxContract<Player>;
    let teamOwner: SandboxContract<TreasuryContract>;
    let player: SandboxContract<TreasuryContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        teamOwner = await blockchain.treasury('owner');
        player = await blockchain.treasury('player');

        teamContract = blockchain.openContract(await Team.fromInit({
            $$type: "TeamInfo",
            name: "test team",
            owner: teamOwner.address,
            seqno: 0n,
            maxParticipantCount: 10n
        }));

        const teamDeployResult = await teamContract.send(
            teamOwner.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(teamDeployResult.transactions).toHaveTransaction({
            from: teamOwner.address,
            to: teamContract.address,
            deploy: true,
            success: true,
        });

        playerContract = blockchain.openContract(await Player.fromInit(player.address));

        const playerDeployResult = await playerContract.send(
            player.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(playerDeployResult.transactions).toHaveTransaction({
            from: player.address,
            to: playerContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should add participant to the team', async () => {
        const participantCountBefore = await teamContract.getParticipantCount();

        const teamDeployResult = await teamContract.send(
            teamOwner.getSender(),
            {
                value: toNano('0.55'),
            },
            {
                $$type: 'AddTeamParticipantRequest',
                player: player.address,
            }
        );

        expect(teamDeployResult.transactions).toHaveTransaction({
            from: teamOwner.address,
            to: teamContract.address,
            success: true,
        });

        
        const participantCountAfter = await teamContract.getParticipantCount();

        expect(participantCountAfter).toBe(participantCountBefore + 1n);
    });

    it('should add participant to the team', async () => {
        const participantCountBefore = await teamContract.getParticipantCount();

        const teamDeployResult = await teamContract.send(
            teamOwner.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'AddTeamParticipantRequest',
                player: player.address,
            }
        );

        expect(teamDeployResult.transactions).toHaveTransaction({
            from: teamOwner.address,
            to: teamContract.address,
            success: true,
        });
        
        const participantCountAfter = await teamContract.getParticipantCount();

        expect(participantCountAfter).toBe(participantCountBefore + 1n);
    });

    it('should add participant to the team', async () => {
        const victoryCountBefore = await teamContract.getVictoryCount();

        const teamDeployResult = await teamContract.send(
            teamOwner.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'VictoryRequest',
                player: player.address,
            }
        );

        expect(teamDeployResult.transactions).toHaveTransaction({
            from: teamOwner.address,
            to: teamContract.address,
            success: true,
        });
        
        const victoryCountAfter = await teamContract.getVictoryCount();

        expect(victoryCountAfter).toBe(victoryCountBefore + 1n);
    });
});
