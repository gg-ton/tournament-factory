import { toNano } from '@ton/core';
import { Match } from '../wrappers/Match';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const match = provider.open(await Match.fromInit());

    await match.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(match.address);

    // run methods on `match`
}
