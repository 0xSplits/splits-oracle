# splits-oracle

## What

Oracle provides an interface (IOracle) allowing for a customization layer on top of other onchain oracles.

`UniV3OracleImpl` is an implementation using Uniswap v3's TWAP oracle.

## Why

Many onchain value flows require fair pricing for token pairs.

## How

[![UniV3OracleImpl sequence diagram](https://mermaid.ink/img/pako:eNplkLFuQjEMRX8l8lrexJYBCQmGDlWLUJneYiWGRk3ikDhFCPHv5JFWaosny7rHvr4XMGwJNBQ6VoqGVg4PGYNSY1Stlt4ZGhaLp_fodvPXjMbTc0heqwPJprLQMnCNUrrcMye1_qJ8Vgld7sOp_uHfG8sJ027-xuyLVoZjqV7-ML8EDRkeTIgznx2gaHvzeGm4P6EVdqcwg0A5oLPt7csEjSAfFGgE3VpLe5xswBivTYpVeHuOBrTkSjOoyaL8pAR6j760KVknnF96lPdErzerIHNC?type=png)](https://mermaid.live/edit#pako:eNplkLFuQjEMRX8l8lrexJYBCQmGDlWLUJneYiWGRk3ikDhFCPHv5JFWaosny7rHvr4XMGwJNBQ6VoqGVg4PGYNSY1Stlt4ZGhaLp_fodvPXjMbTc0heqwPJprLQMnCNUrrcMye1_qJ8Vgld7sOp_uHfG8sJ027-xuyLVoZjqV7-ML8EDRkeTIgznx2gaHvzeGm4P6EVdqcwg0A5oLPt7csEjSAfFGgE3VpLe5xswBivTYpVeHuOBrTkSjOoyaL8pAR6j760KVknnF96lPdErzerIHNC)

### How does it determine fair pricing?

`UniV3OracleImpl` uses Uniswap V3 TWAP oracle.

### How is it governed?

Please be aware, an Oracle's owner has _SIGNIFICANT CONTROL_ (depending on the implementation) of the deployment. It may, at any time for any reason, change the quote pair uniswap pools & TWAP periods. In situations where flows ultimately belong to or benefit more than a single person & immutability is a nonstarter, we strongly recommend using multisigs or DAOs for governance.

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produces a trace of any failing tests

## Natspec

`forge doc --serve --port 4000` - serves natspec docs at http://localhost:4000/
