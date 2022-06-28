from brownie import Lottery, network, MockV3Aggregator, config
from scripts.helpful_scripts import deploy_contract, choose_account


def deploy():
    print("Deploying contract...")
    lottery = deploy_contract()
    print("Contract successfully deployed!")


def start_lottery():
    account = choose_account()
    lottery = deploy_contract()
    lottery.startLottery({"from": account})
    print("The lottery has begun!")


def main():
    deploy()
    start_lottery()
