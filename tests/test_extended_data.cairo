%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc
from src.StarknetId import (
    mint,
    set_extended_verifier_data,
    get_extended_verifier_data,
    get_unbounded_verifier_data,
    set_extended_user_data,
    get_extended_user_data,
    get_unbounded_user_data,
)

@external
func test_verifier_extended_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    ) {
    alloc_locals;
    %{ stop_prank_callable = start_prank(123) %}

    let token_id = 1;
    mint(token_id);
    // should set the avatar of specified token_id to [ 12345, 6789 ]
    set_extended_verifier_data(token_id, 'avatar', 2, new (12345, 6789));
    // should retrieve it by specifying the array length
    let (len, values) = get_extended_verifier_data(token_id, 'avatar', 2, 123);
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    // should retrieve it without specifying the length (stops at 0)
    let (len, values) = get_unbounded_verifier_data(token_id, 'avatar', 123);
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    // should retrieve nothing
    let (len, values) = get_unbounded_verifier_data(token_id, 'yolo', 123);
    assert len = 0;

    // should retrieve an array of specified size full of 0
    let (len, values) = get_extended_verifier_data(token_id, 'yolo', 3, 123);
    assert len = 3;
    assert values[0] = 0;
    assert values[1] = 0;
    assert values[2] = 0;

    %{ stop_prank_callable() %}
    return ();
}

@external
func test_user_extended_data{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    %{ stop_prank_callable = start_prank(123) %}

    let token_id = 1;
    mint(token_id);
    // should set the avatar of specified token_id to [ 12345, 6789 ]
    set_extended_user_data(token_id, 'avatar', 2, new (12345, 6789));
    // should retrieve it by specifying the array length
    let (len, values) = get_extended_user_data(token_id, 'avatar', 2);
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    // should retrieve it without specifying the length (stops at 0)
    let (len, values) = get_unbounded_user_data(token_id, 'avatar');
    assert len = 2;
    assert 12345 = values[0];
    assert 6789 = values[1];

    // should retrieve nothing
    let (len, values) = get_unbounded_user_data(token_id, 'yolo');
    assert len = 0;

    // should retrieve an array of specified size full of 0
    let (len, values) = get_extended_user_data(token_id, 'yolo', 3);
    assert len = 3;
    assert values[0] = 0;
    assert values[1] = 0;
    assert values[2] = 0;

    %{ stop_prank_callable() %}
    return ();
}
