import { toNano } from '@ton/core';
import { Team } from '../wrappers/Team';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const team = provider.open(await Team.fromInit());

    await team.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(team.address);

    // run methods on `team`
}
