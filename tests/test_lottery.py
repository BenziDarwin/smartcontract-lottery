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
    lottery = deploy_contract()
    lottery.setEntranceFee()
    entranceFee = lottery.showEntranceFee()
    assert entranceFee != 0


def test_show_recent_winner():
    lottery = deploy_contract()
    assert lottery.recentWinner() != "0x0000000000000000000000000000000000000000"
