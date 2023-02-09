# Starknet.id Contract

This contract is written in Cairo. It allows to mint identity nfts.
The nft contains fields associated to values. To each field, value can be bound, certified by a user or or other contracts. For the same field there can be multiple values from multiple contracts.

## Official addresses of deployment:
- Goerli: ``0x783a9097b26eae0586373b2ce0ed3529ddc44069d1e0fbc4f66d42b69d6850d``
- Mainnet: ``0x05dbdedc203e92749e2e746e2d40a768d966bd243df04a6b712e222bc040a9af``

## Usage

### For users
```cairo
# mint a nft with id token_id (can be random, must not be already minted)
mint(token_id)

# write a data (my discord id) associated to a token_id of a NFT I own and a type (here the felt 'discord')
set_user_data(token_id, 'discord', 707979046952239197)
```

### For verifiers
```cairo
# confirm this data is correct for this specific type and token_id (e.g. you got a proof)
set_verifier_data(token_id, 'discord', 707979046952239197)
```

### For external services
```cairo
# get data written by the nft owner
get_user_data(token_id, 'discord')

# get data written by the specified verifier
get_verifier_data(token_id, 'discord', verifier_addr)
```

## Building/testing

Testing: ``protostar test``
Building: ``protostar build``
Deploying: ``python deploy.py <private_key>``
