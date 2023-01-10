
%lang starknet

@contract_interface
namespace INFT {
    // returns a json url describing how the token should be displayed
    func get_uri(inft_id) -> (uri_len: felt, uri: felt*) {
    }

    // returns the starknet_id owner of the token
    func get_inft_owner(inft_id) -> (starknet_id: felt) {
    }
}