from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.udc_deployer.deployer import Deployer
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.account.account import Account
from starknet_py.net.signer.stark_curve_signer import KeyPair
import asyncio
import sys

argv = sys.argv

deployer_account_addr = (
    0x00a00373A00352aa367058555149b573322910D54FCDf3a926E3E56D0dCb4b0c
)
deployer_account_private_key = int(argv[1])
# MAINNET: https://alpha-mainnet.starknet.io/
# TESTNET: https://alpha4.starknet.io/
# TESTNET2: https://alpha4-2.starknet.io/
network_base_url = "https://alpha4.starknet.io/"
chainid: StarknetChainId = StarknetChainId.TESTNET
max_fee = int(1e18)
deployer = Deployer()


async def main():
    client: GatewayClient = GatewayClient(
        net={
            "feeder_gateway_url": network_base_url + "feeder_gateway",
            "gateway_url": network_base_url + "gateway",
        }
    )
    account: Account = Account(
        client=client,
        address=deployer_account_addr,
        key_pair=KeyPair.from_private_key(deployer_account_private_key),
        chain=chainid,
    )
    impl_file = open("./build/starknetid.json", "r", encoding="utf-8")
    declare_contract_tx = await account.sign_declare_transaction(
        compiled_contract=impl_file.read(), max_fee=max_fee
    )
    impl_file.close()
    impl_declaration = await client.declare(transaction=declare_contract_tx)
    impl_contract_class_hash = impl_declaration.class_hash
    print("transaction hash:", hex(impl_declaration.transaction_hash))
    print("implementation class hash:", hex(impl_contract_class_hash))


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
