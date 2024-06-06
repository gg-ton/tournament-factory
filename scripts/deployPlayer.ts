import { Address, toNano } from '@ton/core';
import { Player } from '../wrappers/Player';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const player = provider.open(await Player.fromInit(Address.parse("kQD_KopE-zqVkrHoA9A-CGt81fJcNQsGYW9MiYP8xmfIT5Yw")));

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
