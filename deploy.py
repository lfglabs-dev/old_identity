from starkware.starknet.compiler.compile import get_selector_from_name
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
import asyncio
import sys

argv = sys.argv

deployer_account_addr = (
    0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
)
deployer_account_private_key = int(argv[1])
universal_deployer = 0x041A78E741E5AF2FEC34B695679BC6891742439F7AFB8484ECD7766661AD02BF
token = argv[2] if len(argv) > 2 else None
admin = 0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
# MAINNET: https://alpha-mainnet.starknet.io/
# TESTNET: https://alpha4.starknet.io/
# TESTNET2: https://alpha4-2.starknet.io/
network_base_url = "https://alpha4.starknet.io/"
chainid: StarknetChainId = StarknetChainId.TESTNET
max_fee = int(1e16)

DEPLOYER_ABI = [
    {
        "data": [
            {"name": "address", "type": "felt"},
            {"name": "deployer", "type": "felt"},
            {"name": "unique", "type": "felt"},
            {"name": "classHash", "type": "felt"},
            {"name": "calldata_len", "type": "felt"},
            {"name": "calldata", "type": "felt*"},
            {"name": "salt", "type": "felt"},
        ],
        "keys": [],
        "name": "ContractDeployed",
        "type": "event",
    },
    {
        "name": "deployContract",
        "type": "function",
        "inputs": [
            {"name": "classHash", "type": "felt"},
            {"name": "salt", "type": "felt"},
            {"name": "unique", "type": "felt"},
            {"name": "calldata_len", "type": "felt"},
            {"name": "calldata", "type": "felt*"},
        ],
        "outputs": [{"name": "address", "type": "felt"}],
    },
]


async def deploy_contract(
    account_client, class_hash, constructor, salt=0, unique=0
) -> int:
    contract = Contract(
        universal_deployer,
        DEPLOYER_ABI,
        account_client,
    )

    invocation = await contract.functions["deployContract"].invoke(
        class_hash, salt, unique, constructor, max_fee=max_fee
    )
    return invocation.hash


async def main():
    client: GatewayClient = GatewayClient(
        net={
            "feeder_gateway_url": network_base_url + "feeder_gateway",
            "gateway_url": network_base_url + "gateway",
        }
    )
    account: AccountClient = AccountClient(
        client=client,
        address=deployer_account_addr,
        key_pair=KeyPair.from_private_key(deployer_account_private_key),
        chain=chainid,
        supported_tx_version=1,
    )
    impl_file = open("./build/starknetid.json", "r")
    declare_contract_tx = await account.sign_declare_transaction(
        compiled_contract=impl_file.read(), max_fee=max_fee
    )
    impl_file.close()
    impl_declaration = await client.declare(
        transaction=declare_contract_tx, token=token
    )
    impl_contract_class_hash = impl_declaration.class_hash
    print("implementation class hash:", hex(impl_contract_class_hash))

    proxy_file = open("./build/proxy.json", "r")
    declare_contract_tx = await account.sign_declare_transaction(
        compiled_contract=proxy_file.read(), max_fee=max_fee
    )
    proxy_file.close()
    proxy_declaration = await client.declare(
        transaction=declare_contract_tx, token=token
    )
    proxy_contract_class_hash = proxy_declaration.class_hash
    print("proxy class hash:", hex(proxy_contract_class_hash))

    tx_hash = await deploy_contract(
        account,
        proxy_contract_class_hash,
        constructor=[
            impl_contract_class_hash,
            get_selector_from_name("initializer"),
            1,
            admin,
        ],
    )

    print("deployment txhash:", hex(tx_hash))
    # print("proxied contract address:", hex(deployment_resp.contract_address))


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
