import { toNano } from '@ton/core';
import { Player } from '../wrappers/Player';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const player = provider.open(await Player.fromInit());

    await player.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(player.address);

    // run methods on `player`
}
