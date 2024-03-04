# splits-oracle

[Docs](https://docs.0xsplits.xyz/core/oracle)

## What

Oracle provides a generic interface (IOracle) allowing for modular integrations of other onchain oracles (see [Swapper](https://github.com/0xSplits/splits-swapper) for an example integration)

`UniV3OracleImpl` - provides per-pair customization layer (pool, period) on top of Uniswap v3's TWAP oracle

`ChainlinkOracleImpl` - provides per-pair customization layer (path, staleAfter) on top of Chainlink's data feed oracle

## Why

Many onchain value flows require fair pricing for token pairs

## How

[![UniV3OracleImpl sequence diagram](https://mermaid.ink/svg/pako:eNqNkl9PwjAUxb9KU7PsQUiIG4zsgWRDlvhg1Bh52stlu2Bj187uDl0M3939EWFAjC_tTfs7p7c354snOkXuc8v6ihVjQgnyWVsyZtMrZmj7zF5Bgfbg-HQJRsBKYmH_4u3lWiuKIBOyanQNJPfCToyfNNdSm-b6ahJ6N9NRD8iNyMBUByZyIjeaXGJCbVI0f7oVmGiV9vwmi4UXepepU8eR603HfRYSElsgodU_YEJDovd6MA7daH4ROvVzHWc6D-yO3DVbvewsK1axKvC9RJXgrYCNgYyxjgqkSHA4m12_KLF0HgwkEu-yXPpsg_RUasIg06WiosOl1jlbbNFULAdhDj2dyH8ciw_Il86j1rLwWT2xopTU0xwBtWR41gSJ5K0ToEq74vylYfsJn0HXKR_wDE0GIq1T2iYt5m0CY-7XZYpraNrg9WhqFErSz5VKuE-mxAEv8xRoP6X9IaaCtLnvgt_mf_cNmXTr8A)](https://mermaid.live/edit#pako:eNqNk01PAjEQhv9KU0P2ICTEXT7SAwmLbOLBqDFy2suwO2Bjt13bWZQY_rv7IcICMV7aSfu870wn0y-emBS54J3OV6wZk1qSYHXImEevmKEnmLcEh173-HQBVsJSofN-8fpyZTRFkEm1rXQVpPbCRoyfNDPK2Or6ahiObsb9FpBbmYHdHpjIj4JoeIkJjU3R_unmMDE6bfkN5_NROLpMnTr2g9F40GYhIbkBkkb_Aya0JFvZp4MwiGYXoVO_wPfHs6nXkLtqK5ddpxPrWDt8L1AneCthbSFjrKGmSibYm0yuX7Rc-A8WEoV3Wa4EWyM9FYZwmplCk2twZUzO5hu0W5aDtIeaTuQ_ju4D8oX_aIxygpUdc4WiluYIKCW9syJIJm-NAHXaBOeZevUjBIOmUt7lGdoMZFpOaT1pMa8nMOaiDFNcQVUGL1tTolCQed7qhAuyBXZ5kadA-y5xsQLlylNMJRl730x-_QF234Rk7Ds)

### How does it determine fair pricing?

`UniV3OracleImpl` uses Uniswap v3's TWAP oracle. The owner must set per-pair reference pools & may set default & per-pair TWAP periods.

`ChainlinkOracleImpl` - uses Chainlink's data feed oracle. The owner must set per-pair data feed paths.

### How is it governed?

Please be aware, an Oracle's owner has _SIGNIFICANT CONTROL_ (depending on the implementation) of the deployment. It may, at any time for any reason, change the quote pair uniswap pools & TWAP periods. In situations where flows ultimately belong to or benefit more than a single person & immutability is a nonstarter, we strongly recommend using a multisig or DAO for governance.

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produces a trace of any failing tests

## Natspec

`forge doc --serve --port 4000` - serves natspec docs at http://localhost:4000/
