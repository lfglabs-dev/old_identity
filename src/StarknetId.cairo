%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.math import assert_le_felt
from starkware.cairo.common.alloc import alloc
from cairo_contracts.src.openzeppelin.token.erc721.library import ERC721
from cairo_contracts.src.openzeppelin.upgrades.library import Proxy
from src.token_uri import append_number_ascii, set_token_uri_base_util, read_base_token_uri

//
// Events
//
@event
func UserDataUpdate(starknet_id: felt, field: felt, data: felt) {
}

@event
func VerifierDataUpdate(starknet_id: felt, field: felt, data: felt, verifier: felt) {
}

//
// Initializer
//

@external
func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proxy_admin: felt, uri_base_len: felt, uri_base: felt*
) {
    Proxy.initializer(proxy_admin);
    ERC721.initializer('Starknet.id', 'ID');
    set_token_uri_base_util(uri_base_len, uri_base);
    return ();
}

//
// Storage
//

@storage_var
func user_data(starknet_id: felt, field: felt) -> (data: felt) {
}

@storage_var
func verifier_data(tokenid: felt, field: felt, address: felt) -> (data: felt) {
}

//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(starknet_id);
    return (owner,);
}

@view
func owner_of{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(Uint256(starknet_id, 0));
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(starknet_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (tokenURI_len: felt, tokenURI: felt*) {
    alloc_locals;

    // https://goerli.indexer.starknet.id/uri?id=
    let (arr_len, arr) = read_base_token_uri(0);
    let (size) = append_number_ascii(tokenId, arr + arr_len);
    return (arr_len + size, arr);
}

//
// STARKNET ID specific
//
@view
func get_user_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt
) -> (data: felt) {
    let (data: felt) = user_data.read(starknet_id, field);
    return (data,);
}

@view
func get_verifier_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, address: felt
) -> (data: felt) {
    let (data: felt) = verifier_data.read(starknet_id, field, address);
    return (data,);
}

@view
func get_confirmed_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, address: felt
) -> (data: felt) {
    // returns data if user_data = verifier_data
    let (found_user_data: felt) = user_data.read(starknet_id, field);
    let (found_verifier_data: felt) = verifier_data.read(starknet_id, field, address);
    assert found_user_data = found_verifier_data;
    return (found_user_data,);
}

//
// Setters
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, starknet_id: Uint256
) {
    ERC721.approve(to, starknet_id);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, starknet_id: Uint256
) {
    ERC721.transfer_from(_from, to, starknet_id);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, starknet_id: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(_from, to, starknet_id, data_len, data);
    return ();
}

//
// NFT specific
//

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(starknet_id: felt) {
    let (to) = get_caller_address();
    assert_le_felt(starknet_id, (2 ** 128) - 1);
    ERC721._mint(to, Uint256(starknet_id, 0));
    return ();
}

//
// STARKNET ID specific
//
@external
func set_user_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    starknet_id: felt, field: felt, data: felt
) {
    let (owner) = ERC721.owner_of(Uint256(starknet_id, 0));
    let (caller) = get_caller_address();
    assert owner = caller;
    UserDataUpdate.emit(starknet_id, field, data);
    user_data.write(starknet_id, field, data);
    return ();
}

@external
func set_verifier_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    starknet_id: felt, field: felt, data: felt
) {
    let (address) = get_caller_address();
    VerifierDataUpdate.emit(starknet_id, field, data, address);
    verifier_data.write(starknet_id, field, address, data);
    return ();
}

//
// ADMINISTRATION
//
@external
func upgrade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_implementation: felt
) {
    Proxy.assert_only_admin();
    Proxy._set_implementation_hash(new_implementation);
    return ();
}

@external
func set_token_uri_base{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    arr_len: felt, arr: felt*
) {
    Proxy.assert_only_admin();
    set_token_uri_base_util(arr_len, arr);
    return ();
}
