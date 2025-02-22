# CharitaX Smart Contract

A decentralized autonomous organization (DAO) built on Stacks blockchain that automatically contributes a percentage of each transaction to charitable causes. The smart contract implements a governance system allowing token holders to participate in decision-making processes.

## Overview

CharitaX introduces an innovative approach to charitable giving by embedding donations directly into token transactions. Every transfer automatically contributes a configurable percentage to a designated charity wallet, ensuring consistent support for charitable causes through regular token usage.

## Features

### Token Functionality
- Fungible token implementation (SIP-010 compatible)
- Configurable token metadata (name, symbol, decimals, URI)
- Standard transfer capabilities with automatic charity contributions
- Batch transfer support for efficient bulk transactions
- Minting controls for token supply management

### Charitable Giving
- Automatic contribution on every transfer
- Configurable charity percentage (default 0.5%)
- Designated charity wallet for receiving contributions
- Transparent tracking of charitable donations

### Governance System
- Proposal submission mechanism
- Voting system for token holders
- Vote tracking and management
- Token-based voting rights

### Administrative Controls
- Token URI management
- Charity wallet configuration
- Contribution percentage adjustment
- Contract owner privileges

## Technical Specifications

### Constants
```clarity
contract-owner: Principal
err-owner-only: (err u100)
err-not-token-owner: (err u101)
err-insufficient-balance: (err u102)
err-invalid-recipient: (err u103)
err-invalid-amount: (err u104)
err-unauthorized: (err u105)
```

### Data Variables
- `token-name`: ASCII string (32 chars max)
- `token-symbol`: ASCII string (10 chars max)
- `token-decimals`: uint
- `token-uri`: Optional UTF-8 string (256 chars max)
- `charity-percentage`: uint
- `charity-wallet`: Principal

### Public Functions

#### Token Operations
1. `transfer`
   - Parameters: amount (uint), sender (principal), recipient (principal)
   - Transfers tokens between accounts with automatic charity contribution
   - Returns: (response bool uint)

2. `batch-transfer`
   - Parameters: transfers (list of {amount: uint, recipient: principal})
   - Processes multiple transfers efficiently
   - Maximum 10 transfers per batch
   - Returns: (response bool uint)

3. `mint`
   - Parameters: amount (uint), recipient (principal)
   - Restricted to contract owner
   - Creates new tokens
   - Returns: (response bool uint)

#### Governance Functions
1. `submit-proposal`
   - Parameters: proposal-id (uint)
   - Creates new governance proposals
   - Requires token holder status
   - Returns: (response bool uint)

2. `vote`
   - Parameters: proposal-id (uint)
   - Records votes on proposals
   - Requires token holder status
   - Returns: (response bool uint)

#### Administrative Functions
1. `set-token-uri`
   - Parameters: new-uri (optional string-utf8)
   - Updates token metadata URI
   - Owner-only function
   - Returns: (response bool uint)

2. `set-charity-wallet`
   - Parameters: new-wallet (principal)
   - Updates charity wallet address
   - Owner-only function
   - Returns: (response bool uint)

3. `set-charity-percentage`
   - Parameters: new-percentage (uint)
   - Updates charity contribution percentage
   - Owner-only function
   - Maximum 100% (1000 basis points)
   - Returns: (response bool uint)

### Read-Only Functions
- `get-name`: Returns token name
- `get-symbol`: Returns token symbol
- `get-decimals`: Returns token decimals
- `get-token-uri`: Returns token URI
- `get-balance`: Returns account balance
- `get-total-supply`: Returns total token supply
- `get-charity-wallet`: Returns charity wallet address
- `get-charity-percentage`: Returns charity contribution percentage

## Implementation Details

### Charitable Contribution Mechanism
The contract automatically calculates and transfers charitable contributions during each token transfer:
```clarity
charity-amount = (amount * charity-percentage) / 1000
recipient-amount = amount - charity-amount
```

### Batch Transfer Processing
Batch transfers are processed using a fold operation that maintains transaction atomicity:
- All transfers in a batch must succeed
- Maximum 10 transfers per batch
- Includes charity contributions for each transfer

### Governance Implementation
- Token-weighted voting system
- One vote per proposal per address
- Proposals require unique identifiers
- Vote counts tracked in contract storage

## Security Considerations

### Access Controls
- Owner-only functions protected by principal checks
- Transfer validation ensures proper ownership
- Invalid operations revert with specific error codes

### Transaction Validation
- Amount validation prevents zero-value transfers
- Recipient validation prevents invalid addresses
- Balance checks ensure sufficient funds

### Governance Safety
- Token holding requirements for participation
- Proposal ID validation
- Vote counting integrity

## Error Codes
- `u100`: Operation restricted to contract owner
- `u101`: Sender is not token owner
- `u102`: Insufficient balance for operation
- `u103`: Invalid recipient address
- `u104`: Invalid amount specified
- `u105`: Unauthorized operation (token holding required)

## Development Setup

### Testing
1. Clone the repository
2. Install dependencies
3. Run Clarinet console
4. Execute test suite

### Deployment
1. Prepare contract for deployment
2. Set initial parameters
3. Deploy to desired network
4. Verify contract operation
