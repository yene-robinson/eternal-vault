# EternalVault Protocol (EVP)

**Next-Generation Digital Legacy Management on Bitcoin via Stacks Layer 2**

---

## 📖 Overview

**EternalVault Protocol (EVP)** is a decentralized smart contract framework designed to transform digital inheritance into a secure, trustless, and programmable process.

By leveraging **Stacks Layer 2** and anchoring security to Bitcoin’s consensus, EVP provides tamper-proof digital legacy distribution through:

* **Multi-oracle death confirmation**
* **Time-locked inheritance claims**
* **NFT-based succession rights**
* **Cryptographic will validation**
* **Phased distribution mechanisms**
* **On-chain dispute resolution**

This protocol ensures that digital wealth transcends mortality with **mathematical certainty**, eliminating dependence on traditional legal systems.

---

## 🚀 Key Features

* **Secure Beneficiary Registration**
  Owners define heirs, distribution shares, lock periods, and optional NFT allocations.

* **Cryptographic Will Hashing**
  Immutable proof of will authenticity via on-chain hash registration.

* **Oracle-Driven Death Verification**
  Trusted oracles confirm death events with configurable multi-signature thresholds.

* **Time-Locked & Phased Distribution**
  Protects against premature claims and mitigates market shocks from large transfers.

* **NFT Succession Rights**
  Supports inheritance of unique digital collectibles alongside fungible assets.

* **Automated Dispute Resolution**
  On-chain dispute registration with evidence hashes and resolution voting.

* **Emergency & Governance Controls**
  Contract owner can deactivate or update oracle thresholds under controlled conditions.

---

## ⚙️ System Architecture

EternalVault Protocol operates as a **modular Clarity smart contract**, composed of three core subsystems:

1. **Contract Administration & Will Management**

   * Owner initialization
   * Oracle registration
   * Will hash updates

2. **Inheritance & Distribution Engine**

   * Beneficiary mappings
   * Claim functions (standard & phased)
   * NFT ownership tracking

3. **Governance & Dispute Resolution**

   * Multi-oracle death confirmation
   * Dispute initiation with cryptographic evidence
   * Resolution via voting thresholds

---

## 🔑 Contract Architecture

### **State Variables**

* `contract-owner` – Principal authorized to manage core functions.
* `oracles` – Trusted oracle set with verification rights.
* `beneficiaries` – Mapping of inheritance details (shares, lock, NFTs, status).
* `nft-ownership` – Tracks NFT transfers.
* `death-confirmed` – Boolean signaling verified death event.
* `last-will-hash` – Stores cryptographic proof of will authenticity.
* `inheritance-tax` – Protocol-level fee applied during distribution.

### **Error Constants**

Comprehensive error codes (e.g., `ERR-NOT-AUTHORIZED`, `ERR-TIME-LOCK`, `ERR-INVALID-HASH`) enforce deterministic validation across all flows.

### **Core Functions**

* **Administration**

  * `initialize-contract` → Registers oracle set.
  * `add-beneficiary` → Adds inheritance records.
  * `update-will-hash` → Updates will cryptographic hash.

* **Oracle System**

  * `confirm-death` → Increments confirmation count, sets `death-confirmed`.
  * `update-required-confirmations` → Adjusts oracle threshold.

* **Inheritance Distribution**

  * `claim-inheritance` → Standard inheritance with tax & NFT transfers.
  * `claim-phase-1` → Partial phased release (mitigates liquidity shocks).

* **Dispute Resolution**

  * `raise-dispute` → Registers cryptographic evidence.
  * `resolve-dispute` → Marks disputes as resolved.

* **Administrative Controls**

  * `deactivate-contract` → Emergency shutdown.

* **Read-Only Interfaces**

  * `get-beneficiary-info` → Returns beneficiary details.
  * `get-contract-status` → Returns protocol state overview.
  * `get-nft-owner` → Queries NFT ownership history.

---

## 🔄 Data Flow

1. **Initialization Phase**

   * Contract owner registers trusted oracle set.
   * Will hash stored for validation.
   * Beneficiaries added with shares, lock periods, and NFT allocations.

2. **Verification Phase**

   * Upon death, oracles submit confirmations.
   * Once threshold reached → `death-confirmed = true`.

3. **Distribution Phase**

   * Beneficiaries claim inheritance after lock period.
   * NFTs transferred directly to rightful heir.
   * Fungible assets distributed with tax deduction.
   * Optional phased distribution prevents liquidity shocks.

4. **Dispute Resolution Phase**

   * Disputes raised with cryptographic evidence.
   * Resolution determined by vote threshold.

---

## 📡 Security & Guarantees

* **Bitcoin-anchored finality** via Stacks consensus.
* **Immutable inheritance rules** enforced by Clarity.
* **Oracle-based verification** for real-world events.
* **Tamper-proof dispute records** through on-chain evidence hashes.
* **Fail-safe controls** with emergency contract deactivation.

---

## 📖 Read-Only Queries

| Function               | Returns                                                        |
| ---------------------- | -------------------------------------------------------------- |
| `get-beneficiary-info` | Full beneficiary struct (shares, lock, NFTs, claimed status)   |
| `get-contract-status`  | Active state, death confirmation, oracle thresholds, will hash |
| `get-nft-owner`        | Principal currently registered as NFT holder                   |

---

## 🏗️ Future Extensions

* DAO-driven oracle governance.
* zk-SNARK-based privacy-preserving will verification.
* Multi-chain asset inheritance.
* Off-chain storage integration for full will documents.

---

## 📜 License

MIT License.
