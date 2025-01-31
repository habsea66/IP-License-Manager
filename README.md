# IP License Manager

## Overview

This smart contract is built using **Clarity** on the **Stacks blockchain** to manage Intellectual Property (IP) licenses. It allows issuing, transferring, and renewing licenses while enforcing security through validation checks.

## Features

- **Issue Licenses**: Only the contract deployer can issue new licenses.
- **Transfer Licenses**: Owners can transfer licenses to a new owner.
- **Renew Licenses**: Owners can extend the expiration of existing licenses.
- **License Tracking**: Read functions provide license details and the total issued licenses.

## Functions

### Public Functions

- `issue-license(license-id, owner, expiry-block)`: Issues a new license to an owner.
- `transfer-license(license-id, new-owner)`: Transfers a license to another user.
- `renew-license(license-id, new-expiry-block)`: Extends the expiry date of an existing license.

### Read-Only Functions

- `get-license(license-id)`: Retrieves license details.
- `get-total-licenses()`: Returns the total number of licenses issued.

## Security & Validations

- Only the contract deployer can issue new licenses.
- Transfers and renewals require ownership verification.
- Expiry blocks must be in the future.
- Prevents issuing or transferring licenses to a burn address.

## Deployment

This contract is designed to be deployed on the **Stacks blockchain** using **Clarity**
