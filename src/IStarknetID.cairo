%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IStarknetid {
    func name() -> (name: felt) {
    }

    func symbol() -> (symbol: felt) {
    }

    func balanceOf(owner: felt) -> (balance: Uint256) {
    }

    func ownerOf(token_id: Uint256) -> (owner: felt) {
    }

    func owner_of(token_id: felt) -> (owner: felt) {
    }

    func getApproved(token_id: Uint256) -> (approved: felt) {
    }

    func isApprovedForAll(owner: felt, operator: felt) -> (is_approved: felt) {
    }

    func tokenURI(tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    }

    func get_user_data(token_id: felt, field: felt) -> (data: felt) {
    }

    func get_verifier_data(token_id: felt, field: felt, address: felt) -> (data: felt) {
    }

    func get_confirmed_data(token_id: felt, field: felt, address: felt) -> (data: felt) {
    }

    func approve(to: felt, token_id: Uint256) {
    }

    func setApprovalForAll(operator: felt, approved: felt) {
    }

    func transferFrom(_from: felt, to: felt, token_id: Uint256) {
    }

    func safeTransferFrom(_from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*) {
    }

    func mint(token_id: felt) {
    }

    func set_user_data(token_id: felt, field: felt, data: felt) {
    }

    func set_verifier_data(token_id: felt, field: felt, data: felt) {
    }
}
