%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc
from src.StarknetId import (
    mint,
    set_extended_verifier_data,
    get_extended_verifier_data,
    get_extended_unknown_verifier_data,
)

@external
func test_set_extended_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    %{ stop_prank_callable = start_prank(123) %}

    let token_id = 1;
    mint(token_id);
    set_extended_verifier_data(token_id, 'avatar', 2, new (12345, 6789));
    let (len, values) = get_extended_verifier_data(token_id, 'avatar', 123, 2);
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    let (len, values) = get_extended_unknown_verifier_data(token_id, 'avatar', 123);
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    let (len, values) = get_extended_unknown_verifier_data(token_id, 'yolo', 123);
    assert len = 0;
    let (len, values) = get_extended_verifier_data(token_id, 'yolo', 123, 3);
    assert len = 3;
    assert values[0] = 0;
    assert values[1] = 0;
    assert values[2] = 0;

    %{ stop_prank_callable() %}
    return ();
}
