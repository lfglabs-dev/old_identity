%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func owner(inft_id) -> (starknet_id: felt) {
}

@view
func get_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(inft_id) -> (
    uri_len: felt, uri: felt*
) {
    return (0, new ());
}

@view
func get_inft_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(inft_id) -> (
    starknet_id: felt
) {
    return owner.read(inft_id);
}

// you can mint it on any starknet_id as long as it is not already minted
@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(inft_id, starknet_id) {
    let (starknet_id_owner) = owner.read(inft_id);
    assert starknet_id_owner = 0;
    owner.write(inft_id, starknet_id);
    return ();
}

@contract_interface
namespace DummyINFT {
    func mint(inft_id, starknet_id) {
    }
}
