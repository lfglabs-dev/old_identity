# Starknet.id Contract

This contract is written in Cairo. It allows to mint identity nfts.

## Official addresses of deployment:
- Goerli: ``0x064dfcb0d23d57fa0bc0d4b40a3e55f21534fe39acbe8e44561fa0c1a27a6e72``
- Mainnet: ``none``

## Usage

### For users
```cairo
# mint a nft with id token_id (can be random, must not be already minted)
mint(token_id)

# write a data (my discord id) associated to a token_id of a NFT I own and a type (here the felt 'discord')
set_data(token_id, 'discord', 707979046952239197)
```

### For verifiers
```cairo
# confirm this data is correct for this specific type and token_id (e.g. you got a proof)
confirm_validity(token_id, 'discord', 707979046952239197)
```

### For external services
```cairo
# get unverified data
get_data(token_id, 'discord')

# check if a data is correct according for a specific verifier
is_valid(token_id, 'discord', 707979046952239197, verifier_addr)

# get data only if verified
get_valid_data(token_id, 'discord', verifier_addr)
```

## Building/testing

Testing: ``protostar test --cairo-path ./lib/cairo_contracts/src/``
BUilding: ``protostar build --cairo-path ./lib/cairo_contracts/src/``