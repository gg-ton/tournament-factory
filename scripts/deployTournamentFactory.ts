import { toNano } from '@ton/core';
import { TournamentFactory } from '../wrappers/TournamentFactory';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const tournamentFactory = provider.open(await TournamentFactory.fromInit());

    await tournamentFactory.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(tournamentFactory.address);

    // run methods on `tournamentFactory`
}
