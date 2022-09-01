# 0.035714
# 3571400000000000

from brownie import Lottery, accounts, config, network
from web3 import Web3


def test_get_entrance_fee():
    account = accounts[0]
    lottery = Lottery.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        {"from": account},
    )
    ent_fee = lottery.getEntranceFee()
    print(ent_fee)

    assert lottery.getEntranceFee() > Web3.toWei(0.03, "ether")
    assert lottery.getEntranceFee() < Web3.toWei(0.04, "ether")
