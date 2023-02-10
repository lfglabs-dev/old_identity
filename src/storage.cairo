%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_write, storage_read
from starkware.cairo.common.alloc import alloc

func write_extended_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr: felt, data_len: felt, data: felt*
) {
    if (data_len == 0) {
        return ();
    }
    let written = [data];
    storage_write(addr, written);
    return write_extended_data(addr + 1, data_len - 1, data + 1);
}

func read_extended_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr: felt, data_len: felt
) -> (data_len: felt, data: felt*) {
    if (data_len == 0) {
        let (data) = alloc();
        return (0, data);
    }

    let (rest_len, rest) = read_extended_data(addr, data_len - 1);
    let (to_add) = storage_read(addr + rest_len);
    assert rest[rest_len] = to_add;
    return (rest_len + 1, rest);
}

// length should be zero at first
func read_unbounded_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    arr: felt*, addr: felt, length: felt
) -> (data_len: felt) {
    let (to_add) = storage_read(addr);
    if (to_add == 0) {
        return (length,);
    }
    assert [arr] = to_add;
    return read_unbounded_data(arr + 1, addr + 1, length + 1);
}
