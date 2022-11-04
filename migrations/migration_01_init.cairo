%lang starknet

@external
func up() {
    %{
        from starkware.starknet.compiler.compile import get_selector_from_name
        admin = 0x048F24D0D0618fa31813DB91a45d8be6c50749e5E19ec699092CE29aBe809294
        logic_contract_class_hash = declare("./build/logic.json").class_hash
        storage_contract_address = deploy_contract("./build/proxy.json", [logic_contract_class_hash,
            get_selector_from_name("initializer"), 1, admin]).contract_address
    %}
    return ();
}

@external
func down() {
    %{ assert False, "Not implemented" %}
    return ();
}
