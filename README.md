# splits-oracle

## What

Oracle provides an interface (IOracle) allowing for a customization layer on top of other onchain oracles.

`UniV3OracleImpl` is an implementation using Uniswap v3's TWAP oracle.

## Why

Many onchain value flows require fair pricing for token pairs.

## How

[![UniV3OracleImpl sequence diagram](https://mermaid.ink/img/pako:eNqNk01PAjEQhv9KU0P2ICTEXT7SAwmLbOLBqDFy2suwO2Bjt13bWZQY_rv7IcICMV7aSfu870wn0y-emBS54J3OV6wZk1qSYHXImEevmKEnmLcEh173-HQBVsJSofN-8fpyZTRFkEm1rXQVpPbCRoyfNDPK2Or6ahiObsb9FpBbmYHdHpjIj4JoeIkJjU3R_unmMDE6bfkN5_NROLpMnTr2g9F40GYhIbkBkkb_Aya0JFvZp4MwiGYXoVO_wPfHs6nXkLtqK5ddpxPrWDt8L1AneCthbSFjrKGmSibYm0yuX7Rc-A8WEoV3Wa4EWyM9FYZwmplCk2twZUzO5hu0W5aDtIeaTuQ_ju4D8oX_aIxygpUdc4WiluYIKCW9syJIJm-NAHXaBOeZevUjBIOmUt7lGdoMZFpOaT1pMa8nMOaiDFNcQVUGL1tTolCQed7qhAuyBXZ5kadA-y5xsQLlylNMJRl730x-_QF234Rk7Ds?type=svg)](https://mermaid.live/edit#pako:eNqNk01PAjEQhv9KU0P2ICTEXT7SAwmLbOLBqDFy2suwO2Bjt13bWZQY_rv7IcICMV7aSfu870wn0y-emBS54J3OV6wZk1qSYHXImEevmKEnmLcEh173-HQBVsJSofN-8fpyZTRFkEm1rXQVpPbCRoyfNDPK2Or6ahiObsb9FpBbmYHdHpjIj4JoeIkJjU3R_unmMDE6bfkN5_NROLpMnTr2g9F40GYhIbkBkkb_Aya0JFvZp4MwiGYXoVO_wPfHs6nXkLtqK5ddpxPrWDt8L1AneCthbSFjrKGmSibYm0yuX7Rc-A8WEoV3Wa4EWyM9FYZwmplCk2twZUzO5hu0W5aDtIeaTuQ_ju4D8oX_aIxygpUdc4WiluYIKCW9syJIJm-NAHXaBOeZevUjBIOmUt7lGdoMZFpOaT1pMa8nMOaiDFNcQVUGL1tTolCQed7qhAuyBXZ5kadA-y5xsQLlylNMJRl730x-_QF234Rk7Ds)

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
