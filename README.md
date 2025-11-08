# 💝 Transparent Charity Donation Tracking

A blockchain-based smart contract for transparent charity campaign management on the Stacks blockchain. Track donations, manage campaigns, and ensure complete transparency in charitable giving.

## ✨ Features

- 🎯 **Campaign Creation** - Create charity campaigns with customizable goals and beneficiaries
- 💰 **Donation Tracking** - Complete transparency of all donations with timestamps
- 📊 **Real-time Statistics** - Track total raised funds and individual donor contributions
- 🔒 **Secure Withdrawals** - Only beneficiaries can withdraw funds from their campaigns
- 🎚️ **Campaign Management** - Toggle campaign status and update goals
- 📜 **Full Audit Trail** - All transactions are permanently recorded on-chain

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Transparent-Charity-Donation-Tracking.git
cd Transparent-Charity-Donation-Tracking
```

2. Check the contract:
```bash
clarinet check
```

3. Run tests (if available):
```bash
clarinet test
```

## 📖 Contract Functions

### Public Functions

#### `create-campaign`
Create a new charity campaign.

**Parameters:**
- `name` (string-ascii 100) - Campaign name
- `description` (string-ascii 500) - Campaign description
- `beneficiary` (principal) - Address that can withdraw funds
- `goal` (uint) - Fundraising goal in microSTX

**Returns:** Campaign ID

```clarity
(contract-call? .Transparent-Charity-Donation-Tracking create-campaign 
  "Save the Forest" 
  "Help us plant 1000 trees" 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  u1000000)
```

#### `donate`
Make a donation to a campaign.

**Parameters:**
- `campaign-id` (uint) - The campaign to donate to
- `amount` (uint) - Donation amount in microSTX

**Returns:** boolean

```clarity
(contract-call? .Transparent-Charity-Donation-Tracking donate u0 u100000)
```

#### `withdraw`
Withdraw funds from a campaign (beneficiary only).

**Parameters:**
- `campaign-id` (uint) - Campaign to withdraw from
- `amount` (uint) - Amount to withdraw in microSTX

**Returns:** boolean

```clarity
(contract-call? .Transparent-Charity-Donation-Tracking withdraw u0 u50000)
```

#### `toggle-campaign-status`
Activate or deactivate a campaign (creator only).

**Parameters:**
- `campaign-id` (uint) - Campaign to toggle

**Returns:** boolean

```clarity
(contract-call? .Transparent-Charity-Donation-Tracking toggle-campaign-status u0)
```

#### `update-campaign-goal`
Update the fundraising goal (creator only).

**Parameters:**
- `campaign-id` (uint) - Campaign to update
- `new-goal` (uint) - New goal amount

**Returns:** boolean

```clarity
(contract-call? .Transparent-Charity-Donation-Tracking update-campaign-goal u0 u2000000)
```

### Read-Only Functions

#### `get-campaign`
Get campaign details by ID.

**Parameters:**
- `campaign-id` (uint)

**Returns:** Campaign data or none

#### `get-donation`
Get a specific donor's total donation to a campaign.

**Parameters:**
- `campaign-id` (uint)
- `donor` (principal)

**Returns:** Donation data or none

#### `get-campaign-donation`
Get details of a specific donation by index.

**Parameters:**
- `campaign-id` (uint)
- `donation-index` (uint)

**Returns:** Donation details or none

#### `get-campaign-donation-count`
Get total number of donations for a campaign.

**Parameters:**
- `campaign-id` (uint)

**Returns:** Count object

#### `get-donor-total`
Get total donations made by a donor across all campaigns.

**Parameters:**
- `donor` (principal)

**Returns:** Total object

#### `get-campaign-withdrawal`
Get withdrawal details by index.

**Parameters:**
- `campaign-id` (uint)
- `withdrawal-index` (uint)

**Returns:** Withdrawal details or none

#### `get-campaign-withdrawal-count`
Get total number of withdrawals for a campaign.

**Parameters:**
- `campaign-id` (uint)

**Returns:** Count object

#### `get-current-nonce`
Get the next campaign ID.

**Returns:** uint

## 🔐 Error Codes

- `u100` - Owner only operation
- `u101` - Campaign not found
- `u102` - Unauthorized action
- `u103` - Invalid amount (must be > 0)
- `u104` - Already exists
- `u105` - Campaign is inactive
- `u106` - Goal already reached
- `u107` - Insufficient funds
- `u108` - Campaign is active

## 🎯 Use Cases

- 🏥 **Medical Fundraising** - Transparent medical expense campaigns
- 🌍 **Environmental Projects** - Track donations for conservation efforts
- 🎓 **Education Initiatives** - Scholarship and school funding campaigns
- 🏠 **Disaster Relief** - Emergency response fundraising
- 🐾 **Animal Welfare** - Pet rescue and shelter support

## 🛠️ Development

### Project Structure

```
Transparent-Charity-Donation-Tracking/
├── contracts/
│   └── Transparent-Charity-Donation-Tracking.clar
├── tests/
├── Clarinet.toml
└── README.md
```

### Testing

Create tests in the `tests/` directory using Clarinet's testing framework:

```bash
clarinet test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

Built with Clarity for the Stacks blockchain ecosystem.

---

Made with 💜 for transparent charitable giving
