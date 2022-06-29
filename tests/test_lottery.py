from scripts.deploy import deploy
from scripts.helpful_scripts import choose_account, deploy_contract


def test_deploy():
    account = choose_account()
    lottery = deploy_contract()
    assert lottery.showAdminAccount() == account


def test_request_random_words():
    account = choose_account()
    lottery = deploy_contract()
    txn = lottery.requestRandomWords({"from": account})
    txn.wait(2)
    assert lottery.showRandomWords() != 0


def test_get_entrance_fee():
    account = choose_account()
    lottery = deploy()
    lottery.setEntranceFee()
    entranceFee = lottery.showEntranceFee()
    assert entranceFee != 0
