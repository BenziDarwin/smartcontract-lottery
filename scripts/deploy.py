from scripts.helpful_scripts import choose_account, deploy_contract, fund_with_link
import time


def deploy():
    print("Deploying contract...")
    deploy_contract()
    print("Contract successfully deployed!")


def start_lottery():
    account = choose_account()
    lottery = deploy_contract()
    txn = lottery.startLottery({"from": account})
    txn.wait(1)
    print("The lottery has begun!")


def enter_lottery():
    account = choose_account()
    lottery = deploy_contract()
    value = lottery.showEntranceFee()
    txn = lottery.addParticipant({"from": account, "value": value})
    txn.wait(1)
    print(f"Participant {lottery.showRecentEntry()} successfully added!")


def end_lottery():
    account = choose_account()
    lottery = deploy_contract()
    fund_with_link(lottery.address)
    txn = lottery.endLottery({"from": account})
    print("Ending lottery")
    txn.wait(1)
    check_recent_winner()
    print(f"{lottery.recentWinner()} is the winner of this lottery!")


def check_recent_winner():
    lottery = deploy_contract()
    while lottery.recentWinner() == "0x0000000000000000000000000000000000000000":
        print("Calculating winner...")
        time.sleep(10)

    print(f"We have a winner! {lottery.recentWinner()}")


def main():
    deploy()
    start_lottery()
    enter_lottery()
    end_lottery()
