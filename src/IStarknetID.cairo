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

    func ownerOf(starknet_id: Uint256) -> (owner: felt) {
    }

    func owner_of(starknet_id: felt) -> (owner: felt) {
    }

    func getApproved(starknet_id: Uint256) -> (approved: felt) {
    }

    func isApprovedForAll(owner: felt, operator: felt) -> (is_approved: felt) {
    }

    func tokenURI(tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    }

    func get_user_data(starknet_id: felt, field: felt) -> (data: felt) {
    }

    func get_verifier_data(starknet_id: felt, field: felt, address: felt) -> (data: felt) {
    }

    func get_equipped_starknet_id(inft_contract, inft_id) -> (starknet_id: felt) {
    }

    func approve(to: felt, starknet_id: Uint256) {
    }

    func setApprovalForAll(operator: felt, approved: felt) {
    }

    func transferFrom(_from: felt, to: felt, starknet_id: Uint256) {
    }

    func safeTransferFrom(
        _from: felt, to: felt, starknet_id: Uint256, data_len: felt, data: felt*
    ) {
    }

    func mint(starknet_id: felt) {
    }

    func set_user_data(starknet_id: felt, field: felt, data: felt) {
    }

    func set_verifier_data(starknet_id: felt, field: felt, data: felt) {
    }

    func equip(inft_contract: felt, inft_id: felt) {
    }

    func unequip(inft_contract: felt, inft_id: felt) {
    }
}
