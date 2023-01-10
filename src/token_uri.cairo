%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_unsigned_div_rem
from starkware.cairo.common.alloc import alloc

@storage_var
func token_uri_base(char_id: felt) -> (ascii_code: felt) {
}

func read_base_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(i) -> (
    arr_len: felt, arr: felt*
) {
    let (value) = token_uri_base.read(i);
    if (value == 0) {
        let (arr) = alloc();
        return (0, arr);
    }

    let (arr_len, arr) = read_base_token_uri(i + 1);
    let (value) = token_uri_base.read(arr_len);
    assert arr[arr_len] = value - 1;
    return (arr_len + 1, arr);
}

func set_token_uri_base_util{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    arr_len: felt, arr: felt*
) {
    if (arr_len == 0) {
        return ();
    }

    tempvar next_arr_len = arr_len - 1;
    token_uri_base.write(next_arr_len, 1 + arr[next_arr_len]);
    return set_token_uri_base_util(next_arr_len, arr);
}

func append_number_ascii{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    num: Uint256, arr: felt*
) -> (added_len: felt) {
    alloc_locals;
    local ten: Uint256 = Uint256(10, 0);
    let (q: Uint256, r: Uint256) = uint256_unsigned_div_rem(num, ten);
    let digit = r.low + 48;  // ascii

    if (q.low == 0 and q.high == 0) {
        assert arr[0] = digit;
        return (1,);
    }

    let (added_len) = append_number_ascii(q, arr);
    assert arr[added_len] = digit;
    return (added_len + 1,);
}
