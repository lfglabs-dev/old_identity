%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.math import assert_nn, assert_not_zero
from starkware.cairo.common.alloc import alloc
from cairo_contracts.src.openzeppelin.token.erc721.library import ERC721
from cairo_contracts.src.openzeppelin.upgrades.library import Proxy
from src.token_uri import append_number_ascii, set_token_uri_base_util, read_base_token_uri
from src.storage import write_extended_data, read_extended_data, read_unbounded_data
from src.inft import INFT

//
// Events
//
@event
func UserDataUpdate(starknet_id: felt, field: felt, data: felt) {
}

@event
func ExtendedUserDataUpdate(starknet_id: felt, field: felt, data_len: felt, data: felt*) {
}

@event
func VerifierDataUpdate(starknet_id: felt, field: felt, data: felt, verifier: felt) {
}

@event
func ExtendedVerifierDataUpdate(
    starknet_id: felt, author: felt, field: felt, data_len: felt, data: felt*
) {
}

@event
func on_inft_equipped(inft_contract, inft_id: felt, starknet_id: felt) {
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
func starknet_id_data(starknet_id: felt, field: felt, author: felt) -> (first_data: felt) {
}

@storage_var
func user_data(starknet_id: felt, field: felt) -> (data: felt) {
}

@storage_var
func verifier_data(starknet_id: felt, field: felt, address: felt) -> (data: felt) {
}

@storage_var
func inft_equipped_by(inft_contract: felt, inft_id: felt) -> (starknet_id: felt) {
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
func get_extended_user_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, length: felt
) -> (data_len: felt, data: felt*) {
    let (addr: felt) = user_data.addr(starknet_id, field);
    return read_extended_data(addr, length);
}

@view
func get_unbounded_user_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt
) -> (data_len: felt, data: felt*) {
    alloc_locals;
    let (arr) = alloc();
    let (addr: felt) = user_data.addr(starknet_id, field);
    let (arr_len) = read_unbounded_data(arr, addr, 0);
    return (arr_len, arr);
}

@view
func get_verifier_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, address: felt
) -> (data: felt) {
    let (data: felt) = verifier_data.read(starknet_id, field, address);
    return (data,);
}

@view
func get_extended_verifier_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, length: felt, address: felt
) -> (data_len: felt, data: felt*) {
    let (addr: felt) = verifier_data.addr(starknet_id, field, address);
    return read_extended_data(addr, length);
}

@view
func get_unbounded_verifier_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    starknet_id: felt, field: felt, address: felt
) -> (data_len: felt, data: felt*) {
    alloc_locals;
    let (arr) = alloc();
    let (addr: felt) = verifier_data.addr(starknet_id, field, address);
    let (arr_len) = read_unbounded_data(arr, addr, 0);
    return (arr_len, arr);
}

@view
func get_equipped_starknet_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    inft_contract, inft_id
) -> (starknet_id: felt) {
    let (starknet_id) = inft_equipped_by.read(inft_contract, inft_id);
    return (starknet_id,);
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
    // ensures 0 < starknet_id < 2**128
    with_attr error_message("You can only mint a token whose id is within the range ] 0; 2^128 [") {
        assert_nn(starknet_id);
        assert_not_zero(starknet_id);
    }
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

// note: when working with multiple sizes, make sure to write data_len+1 with last_value = 0
@external
func set_extended_user_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    starknet_id: felt, field: felt, data_len: felt, data: felt*
) {
    alloc_locals;
    let (owner) = ERC721.owner_of(Uint256(starknet_id, 0));
    let (caller) = get_caller_address();
    assert owner = caller;
    let (begin_addr) = user_data.addr(starknet_id, field);
    write_extended_data(begin_addr, data_len, data);
    ExtendedUserDataUpdate.emit(starknet_id, field, data_len, data);
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

// note: when working with multiple sizes, make sure to write data_len+1 with last_value = 0
@external
func set_extended_verifier_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    starknet_id: felt, field: felt, data_len: felt, data: felt*
) {
    alloc_locals;
    let (author) = get_caller_address();
    let (begin_addr) = verifier_data.addr(starknet_id, field, author);
    write_extended_data(begin_addr, data_len, data);
    ExtendedVerifierDataUpdate.emit(starknet_id, author, field, data_len, data);
    return ();
}

@external
func equip{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    inft_contract: felt, inft_id: felt
) {
    // ensure caller controls the starknet_id owning this iNFT
    let (starknet_id_owner) = INFT.get_inft_owner(inft_contract, inft_id);
    let (owner: felt) = ERC721.owner_of(Uint256(starknet_id_owner, 0));
    let (caller: felt) = get_caller_address();
    assert owner = caller;

    // update who equips this iNFT
    inft_equipped_by.write(inft_contract, inft_id, starknet_id_owner);

    // emit event
    on_inft_equipped.emit(inft_contract, inft_id, starknet_id_owner);
    return ();
}

@external
func unequip{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    inft_contract: felt, inft_id: felt
) {
    // ensure caller controls the starknet_id owning this iNFT
    let (starknet_id_owner) = INFT.get_inft_owner(inft_contract, inft_id);
    let (owner: felt) = ERC721.owner_of(Uint256(starknet_id_owner, 0));
    let (caller: felt) = get_caller_address();
    assert owner = caller;

    // update who equips this iNFT
    inft_equipped_by.write(inft_contract, inft_id, 0);

    // emit event
    on_inft_equipped.emit(inft_contract, inft_id, 0);
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
func burn_zero{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Proxy.assert_only_admin();
    ERC721._burn(Uint256(0, 0));
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
