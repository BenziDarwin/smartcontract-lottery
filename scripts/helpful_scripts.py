from brownie import accounts, config, network, MockV3Aggregator, Lottery


LOCAL_ENVS = ["development"]
FORKED_ENVS = ["mainnet-fork-dev"]
DECIMALS = 18
STARTING_PRICE = 214234223


def choose_account():
    if network.show_active() in LOCAL_ENVS or network.show_active() in FORKED_ENVS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks(_account):
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": _account})


# def deploy_contract():
#     if network.show_active() in LOCAL_ENVS:
#         account = choose_account()
#         lottery = Lottery.deploy(MockV3Aggregator[0].address, {"from": account})
#         return lottery

#     elif network.show_active() in FORKED_ENVS:
#         account = choose_account()
#         if len(Lottery) <= 0:
#             lottery = Lottery.deploy(
#                 config["networks"][network.show_active()]["eth_usd_price_feed"],
#                 {"from": account},
#             )
#             return lottery
#         else:
#             lottery = Lottery[0]
#             return lottery
