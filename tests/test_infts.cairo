%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.infts.dummy_inft import DummyINFT
from src.IStarknetID import IStarknetid
from src.inft import INFT

@external
func __setup__() {
    %{
        context.starknet_id_contract = deploy_contract("./src/StarknetId.cairo").contract_address
        context.inft_contract = deploy_contract("./tests/infts/dummy_inft.cairo").contract_address
    %}
    return ();
}

@external
func test_equipping{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar starknet_id_contract;
    tempvar inft_contract;
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.inft_contract = context.inft_contract
    %}
    let starknet_id = 1;
    IStarknetid.mint(starknet_id_contract, starknet_id);
    DummyINFT.mint(inft_contract, 123, starknet_id);

    let (owner) = INFT.get_inft_owner(inft_contract, 123);
    assert owner = starknet_id;

    let (equipped) = IStarknetid.get_equipped_starknet_id(starknet_id_contract, inft_contract, 123);
    assert equipped = 0;

    IStarknetid.equip(starknet_id_contract, inft_contract, 123);

    let (equipped) = IStarknetid.get_equipped_starknet_id(starknet_id_contract, inft_contract, 123);
    assert equipped = starknet_id;

    IStarknetid.unequip(starknet_id_contract, inft_contract, 123);

    let (equipped) = IStarknetid.get_equipped_starknet_id(starknet_id_contract, inft_contract, 123);
    assert equipped = 0;

    return ();
}
