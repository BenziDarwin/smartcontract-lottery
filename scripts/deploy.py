from scripts.helpful_scripts import choose_account, deploy_mocks, deploy_contract


def deploy():
    account = choose_account()
    deploy_mocks(account)
    lottery = deploy_contract()


def main():
    deploy()
