import { toNano } from '@ton/core';
import { Tournament } from '../wrappers/Tournament';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const tournament = provider.open(await Tournament.fromInit(0n));

    await tournament.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(tournament.address);

    // run methods on `tournament`
}
