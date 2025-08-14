# ITURA Therapeutic NFT Contract

A Cairo smart contract for the ITURA wellness platform that enables minting of therapeutic NFTs representing users' wellness journey milestones.

## Overview

The ITURA NFT contract extends the OpenZeppelin ERC721 standard with therapeutic-specific functionality:

- **Therapeutic Milestone Tracking**: Each NFT represents a specific therapeutic milestone
- **Session Data Storage**: Encrypted session data hashes stored on-chain
- **Collaborative Art Support**: NFTs can be marked as collaborative community creations
- **Community Contributions**: Set percentage contributions for collaborative pieces
- **Wellness Journey Tracking**: Get user's complete therapeutic progression

## Features

### Core Functionality
- ✅ ERC721 compliant NFT minting and management
- ✅ Therapeutic milestone tracking
- ✅ Session data hash storage
- ✅ Collaborative art support
- ✅ Community contribution system
- ✅ Ownable access control
- ✅ Base URI management
- ✅ User token and milestone queries

### Smart Contract Functions

#### Therapeutic Functions
- `mint_therapeutic_nft(to, milestone, session_hash, is_collaborative)` - Mint NFT with therapeutic data
- `get_therapeutic_data(token_id)` - Get therapeutic milestone and session data
- `update_milestone(token_id, new_milestone)` - Update therapeutic progress
- `set_community_contribution(token_id, percentage)` - Set community contribution percentage
- `get_community_contribution(token_id)` - Get community contribution percentage

#### User Functions  
- `get_user_tokens(user)` - Get all token IDs owned by user
- `get_user_milestones(user)` - Get all therapeutic milestones for user
- `get_total_supply()` - Get total number of minted tokens

#### Admin Functions
- `set_base_uri(new_base_uri)` - Update metadata base URI (owner only)
- `get_base_uri()` - Get current base URI

## Project Structure

```
itura_nft/
├── Scarb.toml              # Project configuration
├── snfoundry.toml          # Starknet Foundry configuration  
├── src/
│   └── lib.cairo           # Main contract implementation
├── tests/
│   └── test_itura_nft.cairo # Contract tests
├── scripts/
│   └── deploy.sh           # Deployment script
└── README.md               # This file
```

## Development

### Prerequisites
- [Scarb](https://docs.swmansion.com/scarb/) - Cairo package manager
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/) - Testing and deployment tools

### Building
```bash
scarb build
```

### Testing
```bash
scarb test
```

### Deployment

1. Update the owner address in `scripts/deploy.sh`
2. Configure your Starknet account
3. Run the deployment script:
```bash
./scripts/deploy.sh
```

## Configuration

### Constructor Parameters
- `name`: NFT collection name (e.g., "ITURA Therapeutic NFT")
- `symbol`: NFT symbol (e.g., "ITURA")  
- `base_uri`: Base URI for token metadata
- `owner`: Contract owner address

### Environment Variables
Update `scripts/deploy.sh` with:
- Network configuration (sepolia/mainnet)
- Owner wallet address
- RPC endpoints

## Integration

### Frontend Integration
1. Update your frontend ABI with the generated contract ABI
2. Use the deployed contract address
3. Implement therapeutic NFT minting workflow
4. Display user's wellness journey and milestones

### Metadata Schema
Token metadata should follow this structure:
```json
{
  "name": "Therapeutic Milestone #1",
  "description": "User's first wellness milestone achievement",
  "image": "https://api.itura.org/images/1.png",
  "attributes": [
    {
      "trait_type": "Therapeutic Milestone",
      "value": 1
    },
    {
      "trait_type": "Is Collaborative", 
      "value": false
    },
    {
      "trait_type": "Community Contribution",
      "value": 0
    }
  ]
}
```

## Security Considerations

- ✅ Access control implemented (Ownable pattern)
- ✅ Token existence validation
- ✅ Owner-only sensitive functions
- ✅ Percentage validation for community contributions
- ✅ Session data stored as hashes (privacy preserved)

## Starknet Integration

- **Chain**: Starknet (Layer 2)
- **Language**: Cairo
- **Standards**: ERC721, OpenZeppelin Components
- **Dependencies**: OpenZeppelin Contracts v0.20.0

## Events

- `TherapeuticNFTMinted` - Emitted when therapeutic NFT is minted
- `MilestoneUpdated` - Emitted when milestone is updated
- `CommunityContributionSet` - Emitted when community contribution is set

## License

This project is part of the ITURA wellness platform.
