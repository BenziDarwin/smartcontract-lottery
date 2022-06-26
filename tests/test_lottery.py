import pytest
from scripts.deploy import deploy
from scripts.helpful_scripts import choose_account


def test_get_entrance_fee():
    account = choose_account()
    lottery = deploy()
    lottery.setEntranceFee()
    entranceFee = lottery.showEntranceFee()
    assert entranceFee != 0


def test_add_participant():
    account = choose_account()
    lottery = deploy()
    lottery.setEntranceFee()
    entrance_fee = lottery.showEntranceFee()

    # Add participant
    lottery.addParticipant({"from": account, "value": entrance_fee})

    assert lottery.participantWithPosition[0] == account
