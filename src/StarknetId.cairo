%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
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

@storage_var
func custom_uri(tokenid : Uint256, index : felt) -> (value : felt):
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
    let (tokenURI_len : felt, tokenURI : felt*) = get_uri(tokenId, 0)

    if tokenURI_len == 0:
        let (data_address) = get_label_location(default_uri)
        return (40, cast(data_address, felt*))
    else:
        return (tokenURI_len, tokenURI)
    end

    default_uri:
    dw 104
    dw 116
    dw 116
    dw 112
    dw 115
    dw 58
    dw 47
    dw 47
    dw 119
    dw 119
    dw 119
    dw 46
    dw 115
    dw 116
    dw 97
    dw 114
    dw 107
    dw 110
    dw 101
    dw 116
    dw 46
    dw 105
    dw 100
    dw 47
    dw 100
    dw 101
    dw 102
    dw 97
    dw 117
    dw 108
    dw 116
    dw 47
    dw 117
    dw 114
    dw 105
    dw 46
    dw 106
    dw 115
    dw 111
    dw 110
end

func get_uri{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, start_index : felt
) -> (tokenURI_len : felt, tokenURI : felt*):
    alloc_locals
    let (value : felt) = custom_uri.read(token_id, start_index)
    if value == 0:
        let (uri : felt*) = alloc()
        return (0, uri)
    end

    let (uri_len, uri) = get_uri(token_id, start_index + 1)
    assert uri[uri_len] = value - 1

    return (uri_len + 1, uri)
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

@external
func set_uri{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, tokenURI_len : felt, tokenURI : felt*
):
    let (owner) = ERC721.owner_of(token_id)
    let (caller) = get_caller_address()
    assert owner = caller
    return _set_uri(token_id, tokenURI_len, tokenURI)
end

func _set_uri{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, tokenURI_len : felt, tokenURI : felt*
):
    if tokenURI_len == 0:
        return ()
    end
    tempvar index = tokenURI_len - 1
    custom_uri.write(token_id, index, [tokenURI] + 1)
    _set_uri(token_id, tokenURI_len - 1, tokenURI + 1)
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
