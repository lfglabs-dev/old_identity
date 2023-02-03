%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write

from src.storage import Storage

@storage_var
func my_var(x: felt, y: felt) -> (a: felt) {
}

@view
func test_my_var{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let (inputs) = alloc();
    assert inputs[0] = 7;
    assert inputs[1] = 6;
    Storage.write(my_var.addr, 2, inputs, 'hello');

    let (result) = my_var.read(7, 6);
    assert result = 'hello';

    let (storage_result) = Storage.read(my_var.addr, 2, inputs);
    assert storage_result = 'hello';
    return ();
}

@storage_var
func example(id: felt) -> (amount: felt) {
}

@view
func test_example{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    Storage.write(example.addr, 1, new (12345), 'hello');
    let (result) = example.read(12345);
    assert result = 'hello';
    return ();
}
