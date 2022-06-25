from brownie import Lottery
from scripts.helpful_scripts import choose_account, deploy_contract, deploy_mocks


def show_entrance_fee():
    account = choose_account()
    deploy_mocks(account)
    lottery = deploy_contract()
    print(lottery.getEntranceFee())


def main():
    show_entrance_fee()
