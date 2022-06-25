from brownie import Lottery, accounts, config, network
from scripts.helpful_scripts import choose_account, deploy_contract


def test_add_participant():
    account = choose_account()
    lottery = deploy_contract()
    entranceFee = lottery.getEntranceFee()

    # Add participant
    lottery.addParticipant({"from": account, "value": entranceFee})

    assert lottery.participants[0] == account
