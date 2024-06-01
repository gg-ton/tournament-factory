import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Tournament } from '../wrappers/Tournament';
import '@ton/test-utils';

describe('Tournament', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let tournament: SandboxContract<Tournament>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');

        tournament = blockchain.openContract(await Tournament.fromInit(deployer.address, 10n));
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and tournament are ready to use
    });
});
