import { Address, toNano } from '@ton/core';
import { Team } from '../wrappers/Team';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const team = provider.open(await Team.fromInit({
        $$type: "TeamInfo",
        name: "Gaming Gladiators",
        owner: Address.parse("kQD_KopE-zqVkrHoA9A-CGt81fJcNQsGYW9MiYP8xmfIT5Yw"),
        seqno: 0n,
    }));

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
