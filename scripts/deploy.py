from scripts.helpful_scripts import choose_account, deploy_contract, fund_with_link


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
    print("Participant successfully added!")


def end_lottery():
    account = choose_account()
    lottery = deploy_contract()
    txn = fund_with_link(lottery.address)
    txn.wait(1)
    txn = lottery.endLottery({"from": account})
    txn.wait(1)
    print("Lottery successfully ended!")


def main():
    deploy()
    start_lottery()
    enter_lottery()
    end_lottery()
