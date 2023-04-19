# splits-oracle

## What

Oracle is an interface allowing for a customization layer on top of onchain oracles.

`UniV3OracleImpl` is an implementation for uniswap v3's twap mechanism.

## Why

[ ]

## Notes

Please be aware, an oracle's owner has _SIGNIFICANT CONTROL_ (depending on the implementation) of the deployment.

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produces a trace of any failing tests
