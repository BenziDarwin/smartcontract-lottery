from brownie import Lottery, network, MockV3Aggregator, config
from scripts.helpful_scripts import deploy_contract


def deploy():
    print("Deploying contract...")
    lottery = deploy_contract()
    print("Contract successfully deployed!")


def main():
    deploy()
