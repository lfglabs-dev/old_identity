from starkware.starknet.compiler.compile import get_selector_from_name
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.udc_deployer.deployer import Deployer
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.gateway_client import GatewayClient
import asyncio
import json
import sys

argv = sys.argv

deployer_account_addr = (
    0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
)
deployer_account_private_key = int(argv[1])
admin = 0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
# MAINNET: https://alpha-mainnet.starknet.io/
# TESTNET: https://alpha4.starknet.io/
# TESTNET2: https://alpha4-2.starknet.io/
network_base_url = "https://alpha4.starknet.io/"
chainid: StarknetChainId = StarknetChainId.TESTNET
max_fee = int(1e16)
# deployer_address=0x041A78E741E5AF2FEC34B695679BC6891742439F7AFB8484ECD7766661AD02BF
deployer = Deployer()
token_uri_base = "https://goerli.indexer.starknet.id/uri?id="


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
    impl_declaration = await client.declare(transaction=declare_contract_tx)
    impl_contract_class_hash = impl_declaration.class_hash
    print("implementation class hash:", hex(impl_contract_class_hash))

    proxy_file = open("./build/proxy.json", "r")
    proxy_content = proxy_file.read()

    declare_contract_tx = await account.sign_declare_transaction(
        compiled_contract=proxy_content, max_fee=max_fee
    )
    proxy_file.close()
    proxy_declaration = await client.declare(transaction=declare_contract_tx)
    proxy_contract_class_hash = proxy_declaration.class_hash
    print("proxy class hash:", hex(proxy_contract_class_hash))

    proxy_json = json.loads(proxy_content)
    abi = proxy_json["abi"]
    deploy_call, address = deployer.create_deployment_call(
        class_hash=proxy_contract_class_hash,
        abi=abi,
        calldata={
            "implementation_hash": impl_contract_class_hash,
            "selector": get_selector_from_name("initializer"),
            "calldata": [admin, len(token_uri_base), *map(ord, token_uri_base)],
        },
    )

    resp = await account.execute(deploy_call, max_fee=int(1e16))
    print("deployment txhash:", hex(resp.transaction_hash))
    print("proxied contract address:", hex(address))


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
