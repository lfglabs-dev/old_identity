%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.alloc import alloc

from cairo_contracts.src.openzeppelin.token.erc721.library import ERC721

#
# Events
#
@event
func UserDataUpdate(token_id : Uint256, field : felt, data : felt):
end

@event
func VerifierDataUpdate(token_id : Uint256, field : felt, data : felt, verifier : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ERC721.initializer('Starknet.id', 'ID')
    return ()
end

#
# Storage Vars
#

@storage_var
func user_data(token_id : Uint256, field : felt) -> (data : felt):
end

@storage_var
func verifier_data(tokenid : Uint256, field : felt, address : felt) -> (data : felt):
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
):
    let (balance : Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (owner : felt):
    let (owner : felt) = ERC721.owner_of(token_id)
    return (owner)
end

@view
func getApproved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (approved : felt):
    let (approved : felt) = ERC721.get_approved(token_id)
    return (approved)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (is_approved : felt):
    let (is_approved : felt) = ERC721.is_approved_for_all(owner, operator)
    return (is_approved)
end

@view
func tokenURI{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    tokenId : Uint256
) -> (tokenURI_len : felt, tokenURI : felt*):
    alloc_locals

    # https://goerli.indexer.starknet.id/uri?id=
    let (array) = alloc()

    assert array[0] = 104
    assert array[1] = 116
    assert array[2] = 116
    assert array[3] = 112
    assert array[4] = 115
    assert array[5] = 58
    assert array[6] = 47
    assert array[7] = 47
    assert array[8] = 103
    assert array[9] = 111
    assert array[10] = 101
    assert array[11] = 114
    assert array[12] = 108
    assert array[13] = 105
    assert array[14] = 46
    assert array[15] = 105
    assert array[16] = 110
    assert array[17] = 100
    assert array[18] = 101
    assert array[19] = 120
    assert array[20] = 101
    assert array[21] = 114
    assert array[22] = 46
    assert array[23] = 115
    assert array[24] = 116
    assert array[25] = 97
    assert array[26] = 114
    assert array[27] = 107
    assert array[28] = 110
    assert array[29] = 101
    assert array[30] = 116
    assert array[31] = 46
    assert array[32] = 105
    assert array[33] = 100
    assert array[34] = 47
    assert array[35] = 117
    assert array[36] = 114
    assert array[37] = 105
    assert array[38] = 63
    assert array[39] = 105
    assert array[40] = 100
    assert array[41] = 61
    let (size) = append_number_ascii(tokenId, array + 42)

    return (42 + size, array)
end

func append_number_ascii{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    num : Uint256, arr : felt*
) -> (added_len : felt):
    alloc_locals
    local ten : Uint256 = Uint256(10, 0)
    let (q : Uint256, r : Uint256) = uint256_unsigned_div_rem(num, ten)
    let digit = r.low + 48 # ascii

    if q.low == 0 and q.high == 0:
        assert arr[0] = digit
        return (1)
    end

    let (added_len) = append_number_ascii(q, arr)
    assert arr[added_len] = digit
    return (added_len + 1)
end

#
# STARKNET ID specific
#
@view
func get_user_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, field : felt
) -> (data : felt):
    let (data : felt) = user_data.read(token_id, field)
    return (data)
end

@view
func get_verifier_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, field : felt, address : felt
) -> (data : felt):
    let (data : felt) = verifier_data.read(token_id, field, address)
    return (data)
end

@view
func get_confirmed_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, field : felt, address : felt
) -> (data : felt):
    # returns data if user_data = verifier_data
    let (found_user_data : felt) = user_data.read(token_id, field)
    let (found_verifier_data : felt) = verifier_data.read(token_id, field, address)
    assert found_user_data = found_verifier_data
    return (found_user_data)
end

#
# Externals
#

@external
func approve{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, token_id : Uint256
):
    ERC721.approve(to, token_id)
    return ()
end

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256
):
    ERC721.transfer_from(_from, to, token_id)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256, data_len : felt, data : felt*
):
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data)
    return ()
end

#
# NFT specific
#

@external
func mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(tokenId : Uint256):
    let (to) = get_caller_address()
    ERC721._mint(to, tokenId)
    return ()
end

#
# STARKNET ID specific
#
@external
func set_user_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256, field : felt, data : felt
):
    let (owner) = ERC721.owner_of(token_id)
    let (caller) = get_caller_address()
    assert owner = caller
    UserDataUpdate.emit(token_id, field, data)
    user_data.write(token_id, field, data)
    return ()
end

@external
func set_verifier_data{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256, field : felt, data : felt
):
    let (address) = get_caller_address()
    VerifierDataUpdate.emit(token_id, field, data, address)
    verifier_data.write(token_id, field, address, data)
    return ()
end
