%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc

# # Import functions
from src.StarknetID import (
    set_verifier_data,
    verifier_data,
    set_user_data,
    user_data,
    mint,
    tokenURI,
    ownerOf,
    append_number_ascii,
)

@external
func test_set_verifier_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)
    let type = 19256242726728292  # # Discord
    let data = 58596348113441803209962597  # # 0xBenaparte

    set_verifier_data(token_id, type, data)

    # # valid case
    let (isValidData) = verifier_data.read(token_id, type, 123)
    assert isValidData = data

    # # not valid case
    let token_id_2 : Uint256 = Uint256(2, 0)
    let type_2 = 'Twitter'  # # Discord
    let data_2 = 'Thomas'  # # 0xBenaparte

    let (isValidData) = verifier_data.read(token_id_2, type_2, 123)
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
func test_set_user_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)
    mint(token_id)
    let type = 19256242726728292  # # Discord
    let data = 58596348113441803209962597  # # 0xBenaparte

    set_user_data(token_id, type, data)

    # valid case
    let (identityData) = user_data.read(token_id, type)
    assert identityData = 58596348113441803209962597

    # not valid case
    let type_2 = 'Twitter'  # # Discord
    let token_id_2 : Uint256 = Uint256(2, 0)

    let (identityData) = user_data.read(token_id, type_2)

    assert identityData = 0
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_uri{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    %{ stop_prank_callable = start_prank(123) %}

    let token_id = Uint256(256, 0)
    mint(token_id)
    let (len_uri, uri) = tokenURI(token_id)
    assert 45 = len_uri
    assert uri[0] = 104
    assert uri[42] = 48+2
    assert uri[43] = 48+5
    assert uri[44] = 48+6

    return ()
end

@external
func test_append_number_ascii{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let number = Uint256(123450, 0)
    let (arr) = alloc()
    assert arr[0] = 1234567898765
    let (added_len) = append_number_ascii(number, arr + 1)
    assert added_len = 6
    assert arr[0] = 1234567898765
    assert arr[1] = 48+1
    assert arr[2] = 48+2
    assert arr[3] = 48+3
    assert arr[4] = 48+4
    assert arr[5] = 48+5
    assert arr[6] = 48+0
    return ()
end
