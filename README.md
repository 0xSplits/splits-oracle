# splits-oracle

## What

Oracle provides an interface (IOracle) allowing for a customization layer on top of other onchain oracles.

`UniV3OracleImpl` is an implementation using Uniswap v3's TWAP oracle.

## Why

Many onchain value flows require fair pricing for token pairs.

## How

[![UniV3OracleImpl sequence diagram](https://mermaid.ink/img/pako:eNptkk1LAzEQhv9KiCx7sD1VLeQgbGsLHkRF7Gkv0820BvOx5kNZSv-72cTarjWBZJg872SSmR1tDEfKaFHsak2I0MIzkkxCSv-GCktGyjU4LEen3hVYAWuJrvzF0-HGaL8EJWTX63pIHoTpvLVCge3mRhrbExfLqp__MTNjOdojOU9jQDpsjOaDeDeLxXQ2HVAerRcDqLqeXS3nZWb2_RaXfVHUutYOPwLqBu8EbC0oQjJVSdHg-Pb28lWL1eTRQiPxXrWSkS3652A8VsoE7V3GpTEtWXyi7UgLwh6z-SP_iei-oF1NnoyRjpH4JhekH2hOgCgZnyXhRfOeBah5Ns5vGqdHMAI5UzqiCq0CwWMDpCLWNBW3piyaHDfQp0Hj10QUgjcvnW4o8zbgiIaWgz_8EmUbkC56kQtv7ENuqtRb-28gqr8I?type=png)](https://mermaid.live/edit#pako:eNptkk1LAzEQhv9KiCx7sD1VLeQgbGsLHkRF7Gkv0820BvOx5kNZSv-72cTarjWBZJg872SSmR1tDEfKaFHsak2I0MIzkkxCSv-GCktGyjU4LEen3hVYAWuJrvzF0-HGaL8EJWTX63pIHoTpvLVCge3mRhrbExfLqp__MTNjOdojOU9jQDpsjOaDeDeLxXQ2HVAerRcDqLqeXS3nZWb2_RaXfVHUutYOPwLqBu8EbC0oQjJVSdHg-Pb28lWL1eTRQiPxXrWSkS3652A8VsoE7V3GpTEtWXyi7UgLwh6z-SP_iei-oF1NnoyRjpH4JhekH2hOgCgZnyXhRfOeBah5Ns5vGqdHMAI5UzqiCq0CwWMDpCLWNBW3piyaHDfQp0Hj10QUgjcvnW4o8zbgiIaWgz_8EmUbkC56kQtv7ENuqtRb-28gqr8I)

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
