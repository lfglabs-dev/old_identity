%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc

# # Import functions
from src.StarknetID import (
    confirm_validity,
    is_valid_data_storage,
    set_data,
    identity_data_storage,
    mint,
    tokenURI,
    ownerOf,
    set_uri,
)

@external
func test_confirm_validity{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)
    let type = 19256242726728292  # # Discord
    let data = 58596348113441803209962597  # # 0xBenaparte

    confirm_validity(token_id, type, data)

    # # valid case
    let (isValidData) = is_valid_data_storage.read(token_id, type, data, 123)
    assert isValidData = 1

    # # not valid case
    let token_id_2 : Uint256 = Uint256(2, 0)
    let type_2 = 'Twitter'  # # Discord
    let data_2 = 'Thomas'  # # 0xBenaparte

    let (isValidData) = is_valid_data_storage.read(token_id_2, type_2, data_2, 123)
    assert isValidData = 0
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)

    mint(token_id)

    # # valid case
    let (owner_ofNftMinted) = ownerOf(token_id)
    assert owner_ofNftMinted = 123
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_set_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)
    mint(token_id)
    let type = 19256242726728292  # # Discord
    let data = 58596348113441803209962597  # # 0xBenaparte

    set_data(token_id, type, data)

    # valid case
    let (identityData) = identity_data_storage.read(token_id, type)
    assert identityData = 58596348113441803209962597

    # not valid case
    let type_2 = 'Twitter'  # # Discord
    let token_id_2 : Uint256 = Uint256(2, 0)

    let (identityData) = identity_data_storage.read(token_id, type_2)

    assert identityData = 0
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_uri{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    %{ stop_prank_callable = start_prank(123) %}

    let token_id = Uint256(1, 0)
    mint(token_id)
    let (len_uri, uri) = tokenURI(token_id)
    assert 40 = len_uri
    assert uri[0] = 104
    assert uri[39] = 110

    let (arr) = alloc()
    assert arr[0] = 12345

    set_uri(token_id, 1, arr)

    let (len_uri, uri) = tokenURI(token_id)
    assert 1 = len_uri
    assert 12345 = uri[0]

    %{ stop_prank_callable() %}

    return ()
end
