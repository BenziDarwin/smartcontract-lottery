from brownie import Lottery
from scripts.helpful_scripts import choose_account, deploy_contract


def test_deploy():
    lottery = deploy_contract()
    assert Lottery[0] == lottery


def test_can_add_participant():
    account = choose_account()
    lottery = deploy_contract()
    txn = lottery.startLottery({"from": account})
    txn.wait(0)
    value = lottery.showEntranceFee({"from": account})
    lottery.addParticipant({"from": account, "value": value})
    assert lottery.participants(0) == account


def test_get_entrance_fee():
    lottery = deploy_contract()
    lottery.showEntranceFee() != 0
