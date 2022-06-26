from brownie import Lottery, network, MockV3Aggregator, config
from scripts.helpful_scripts import (
    choose_account,
    deploy_mocks,
    LOCAL_ENVS,
    FORKED_ENVS,
)


def deploy():
    account = choose_account()
    deploy_mocks(account)
    if network.show_active() in LOCAL_ENVS:
        lottery = Lottery.deploy(MockV3Aggregator[0].address, {"from": account})
        return lottery

    elif network.show_active() in FORKED_ENVS:
        if len(Lottery) <= 0:
            lottery = Lottery.deploy(
                config["networks"][network.show_active()]["eth_usd_price_feed"],
                {"from": account},
            )
            return lottery
        else:
            lottery = Lottery[0]
            return lottery


def main():
    deploy()
