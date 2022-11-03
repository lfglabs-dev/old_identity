%lang starknet

@external
func up() {
    %{
        from starkware.starknet.compiler.compile import get_selector_from_name
        admin = 0x048F24D0D0618fa31813DB91a45d8be6c50749e5E19ec699092CE29aBe809294
        logic_contract_address = deploy_contract("./build/logic.json").contract_address
        storage_contract_address = deploy_contract("./build/proxy.json", [logic_contract_address,
            get_selector_from_name("initializer"), 1, admin]).contract_address
    %}
    return ();
}

@external
func down() {
    %{ assert False, "Not implemented" %}
    return ();
}
