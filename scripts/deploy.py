from brownie import Lottery, network, MockV3Aggregator, config
from scripts.helpful_scripts import (
    choose_account,
    deploy_mocks,
    LOCAL_ENVS,
    FORKED_ENVS,
)


def deploy():
    account = choose_account()
    # deploy_mocks(account)
    if network.show_active() in LOCAL_ENVS:
        exit(0)

    elif network.show_active() in FORKED_ENVS:
        if len(Lottery) <= 0:
            lottery = Lottery.deploy(
                config["networks"][network.show_active()]["eth_usd_price_feed"],
                config["networks"][network.show_active()]["vrfcoordinator_address"],
                config["networks"][network.show_active()]["key_hash"],
                config["networks"][network.show_active()]["linkTokenAddress"],
                {"from": account},
            )
            return lottery
        else:
            lottery = Lottery[0]
            return Lottery
    else:
        if len(Lottery) <= 0:
            lottery = Lottery.deploy(
                config["networks"][network.show_active()]["eth_usd_price_feed"],
                config["networks"][network.show_active()]["vrfcoordinator_address"],
                config["networks"][network.show_active()]["key_hash"],
                config["networks"][network.show_active()]["linkTokenAddress"],
                {"from": account},
            )
            return lottery
        else:
            lottery = Lottery[0]
            return Lottery


def main():
    deploy()
