%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

## Import functions
from src.StarknetId import confirm_validity, is_valid_data_storage, set_data, identity_data_storage, mint, owner_of

@external
func test_confirm_validity{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)
    let type = 19256242726728292 ## Discord
    let data = 58596348113441803209962597 ## 0xBenaparte

    confirm_validity(token_id, type, data)

    ## valid case
    let (isValidData) = is_valid_data_storage.read(token_id, type, data, 123)
    assert isValidData = 1

    ## not valid case
    let token_id_2 : Uint256 = Uint256(2, 0)
    let type_2 = 'Twitter' ## Discord
    let data_2 = 'Thomas' ## 0xBenaparte
    
    let (isValidData) = is_valid_data_storage.read(token_id_2, type_2, data_2, 123)
    assert isValidData = 0

    return ()
end

@external
func test_set_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    let token_id : Uint256 = Uint256(1, 0)
    let type = 19256242726728292 ## Discord
    let data = 58596348113441803209962597 ## 0xBenaparte

    set_data(token_id, type, data)

    ## valid case
    let (identityData) = identity_data_storage.read(token_id, type)
    assert identityData = 58596348113441803209962597

    ## not valid case
    let type_2 = 'Twitter' ## Discord
    let token_id_2 : Uint256 = Uint256(2, 0)

    let (identityData) = identity_data_storage.read(token_id, type_2)
    
    assert identityData = 0
    
    return ()
end

@external
func test_mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}

    let token_id : Uint256 = Uint256(1, 0)

    mint(token_id)

    ## valid case
    let (owner_ofNftMinted) = owner_of(token_id)
    assert owner_ofNftMinted = 123

    return ()
end