import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/tournament_factory.tact',
    options: {
        debug: true,
    },
};
