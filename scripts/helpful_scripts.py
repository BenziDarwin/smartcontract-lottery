from brownie import (
    Contract,
    Lottery,
    MockV3Aggregator,
    LinkToken,
    VRFCoordinatorMock,
    accounts,
    config,
    interface,
    network,
)


LOCAL_ENVS = ["development", "ganache-local"]
FORKED_ENVS = ["mainnet-fork-dev"]
DECIMALS = 18
STARTING_PRICE = 214234223
GAS_PRICE_LINK = 1
BASE_FEE = 1
contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "vrfcoordinator_address": VRFCoordinatorMock,
    "linkTokenAddress": LinkToken,
}


# This function is used to pick an account depending on your network.
def choose_account():
    # Ways of picking an account
    # accounts.add("Private key")
    # accounts.load("Name given to account")
    if network.show_active() in LOCAL_ENVS or network.show_active() in FORKED_ENVS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


# This deploys all mock contracts
def deploy_mocks(
    contract_type,
    decimals=DECIMALS,
    starting_price=STARTING_PRICE,
):
    account = choose_account()

    if contract_type == MockV3Aggregator:
        MockV3Aggregator.deploy(decimals, starting_price, {"from": account})

    if contract_type == LinkToken:
        LinkToken.deploy({"from": account})

    if contract_type == VRFCoordinatorMock:
        VRFCoordinatorMock.deploy(
            config["networks"][network.show_active()]["linkTokenAddress"],
            {"from": account},
        )


def deploy_lottery(_account):
    return Lottery.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vrfcoordinator_address").address,
        config["networks"][network.show_active()]["key_hash"],
        get_contract("linkTokenAddress").address,
        config["networks"][network.show_active()]["fee"],
        {"from": _account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )


# This function is used to deploy the contract.
def deploy_contract():
    account = choose_account()
    if network.show_active() in LOCAL_ENVS:
        lottery = deploy_lottery(account)
        return lottery

    elif network.show_active() in FORKED_ENVS:
        if len(Lottery) <= 0:
            lottery = deploy_lottery(account)
            return lottery
        else:
            lottery = Lottery[0]
            return lottery
    else:
        if len(Lottery) <= 0:
            lottery = deploy_lottery(account)
            return lottery
        else:
            lottery = Lottery[0]
            return lottery


def get_contract(contract_name):
    """
    This will grab the contract addresses of the contract_name
    and will deploy a mock and version of the contract and return the mock contract.
    """
    contract_type = contract_to_mock[contract_name]

    if network.show_active() in LOCAL_ENVS:
        if len(contract_type) <= 0:
            deploy_mocks(contract_type)
            contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
    return contract


def fund_with_link(
    contract_address, account=None, link_token=None, amount=2000000000000000000
):
    account = account if account else choose_account()
    link_token = link_token if link_token else get_contract("linkTokenAddress")
    link_token_contract = interface.LinkTokenInterface(link_token.address)
    txn = link_token_contract.transfer(contract_address, amount, {"from": account})
    txn.wait(1)
    print("Funded contract with Link!")
