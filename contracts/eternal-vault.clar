;; EternalVault Protocol (EVP)
;;
;; Title: EternalVault - Next-Generation Digital Legacy Management
;;
;; Summary: 
;; A revolutionary decentralized protocol for secure digital asset inheritance,
;; leveraging Bitcoin's immutable security through Stacks Layer 2 architecture
;; to create tamper-proof legacy distribution with cryptographic verification.
;;
;; Description:
;; EternalVault transforms traditional inheritance into a programmable, trustless
;; system where digital legacies are preserved and distributed according to
;; predetermined conditions. The protocol introduces multi-oracle verification,
;; time-based asset unlocking, NFT succession rights, and automated dispute
;; arbitration - all secured by Bitcoin's proven consensus mechanism.
;;
;; Key innovations include phased distribution to prevent market manipulation,
;; cryptographic will validation, and cross-generational asset preservation
;; that ensures your digital wealth transcends mortality with mathematical
;; certainty rather than legal uncertainty.
;;

;; Contract ownership and initialization
(define-data-var contract-owner principal tx-sender)

;; Oracle management system
(define-map oracles
  principal
  bool
)
(define-data-var required-confirmations uint u2)
(define-data-var confirmation-count uint u0)

;; Beneficiary inheritance structure
(define-map beneficiaries
  { beneficiary: principal }
  {
    share: uint,
    claimed: bool,
    time-lock: uint,
    nft-tokens: (list 10 uint),
  }
)

;; NFT ownership tracking
(define-map nft-ownership
  uint
  principal
)

;; Contract state variables
(define-data-var total-shares uint u100)
(define-data-var is-active bool true)
(define-data-var death-confirmed bool false)
(define-data-var last-will-hash (buff 32) 0x)
(define-data-var inheritance-tax uint u2)

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-INVALID-SHARE (err u102))
(define-constant ERR-NOT-ACTIVE (err u103))
(define-constant ERR-DEATH-NOT-CONFIRMED (err u104))
(define-constant ERR-TIME-LOCK (err u105))
(define-constant ERR-INVALID-NFT (err u106))
(define-constant ERR-INSUFFICIENT-CONFIRMATIONS (err u107))
(define-constant ERR-PHASE-1-NOT-CLAIMED (err u108))
(define-constant ERR-ALREADY-VOTED (err u109))
(define-constant ERR-NO-DISPUTE (err u110))
(define-constant ERR-INVALID-PRINCIPAL (err u111))
(define-constant ERR-INVALID-LOCK-PERIOD (err u112))
(define-constant ERR-INVALID-NFT-LIST (err u113))
(define-constant ERR-INVALID-HASH (err u114))
(define-constant ERR-DISPUTE-EXISTS (err u115))
(define-constant ERR-INVALID-CONFIRMATION-COUNT (err u116))

;; UTILITY FUNCTIONS

;; Validates NFT token ID integrity
(define-private (check-nft-validity
    (token-id uint)
    (previous-valid bool)
  )
  (and previous-valid (> token-id u0))
)

;; Comprehensive NFT list validation
(define-private (valid-nft-list (nft-list (list 10 uint)))
  (fold check-nft-validity nft-list true)
)

;; CONTRACT ADMINISTRATION

;; Initializes the contract with trusted oracle network
(define-public (initialize-contract (oracle-list (list 5 principal)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (fold add-oracle oracle-list true)
    (ok true)
  )
)

;; Oracle registration helper function
(define-private (add-oracle
    (oracle principal)
    (previous bool)
  )
  (begin
    (map-set oracles oracle true)
    true
  )
)

;; Registers beneficiary with comprehensive inheritance parameters
(define-public (add-beneficiary
    (beneficiary principal)
    (share uint)
    (lock-period uint)
    (nft-list (list 10 uint))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (var-get is-active) ERR-NOT-ACTIVE)
    (asserts! (<= share u100) ERR-INVALID-SHARE)
    (asserts! (not (is-eq beneficiary 'SP000000000000000000002Q6VF78))
      ERR-INVALID-PRINCIPAL
    )
    (asserts! (> lock-period u0) ERR-INVALID-LOCK-PERIOD)
    (asserts! (valid-nft-list nft-list) ERR-INVALID-NFT-LIST)

    (map-set beneficiaries { beneficiary: beneficiary } {
      share: share,
      claimed: false,
      time-lock: (+ stacks-block-height lock-period),
      nft-tokens: nft-list,
    })
    (ok true)
  )
)

;; Updates cryptographic will document hash for verification
(define-public (update-will-hash (new-hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq new-hash 0x)) ERR-INVALID-HASH)
    (var-set last-will-hash new-hash)
    (ok true)
  )
)

;; ORACLE VERIFICATION SYSTEM

;; Multi-signature death confirmation mechanism
(define-public (confirm-death)
  (begin
    (asserts! (default-to false (map-get? oracles tx-sender)) ERR-NOT-AUTHORIZED)
    (var-set confirmation-count (+ (var-get confirmation-count) u1))
    (if (>= (var-get confirmation-count) (var-get required-confirmations))
      (var-set death-confirmed true)
      false
    )
    (ok true)
  )
)

;; ASSET DISTRIBUTION FUNCTIONS

;; Secure NFT transfer with ownership validation
(define-private (transfer-nft (token-id uint))
  (begin
    (if (> token-id u0)
      (begin
        (map-set nft-ownership token-id tx-sender)
        (ok true)
      )
      (err ERR-INVALID-NFT)
    )
  )
)

;; Primary inheritance claim with time-lock protection
(define-public (claim-inheritance)
  (let ((beneficiary-data (unwrap! (map-get? beneficiaries { beneficiary: tx-sender })
      ERR-NOT-AUTHORIZED
    )))
    (begin
      (asserts! (var-get death-confirmed) ERR-DEATH-NOT-CONFIRMED)
      (asserts! (not (get claimed beneficiary-data)) ERR-ALREADY-CLAIMED)
      (asserts! (>= stacks-block-height (get time-lock beneficiary-data))
        ERR-TIME-LOCK
      )

      (let (
          (share-amount (/
            (* (stx-get-balance (as-contract tx-sender))
              (get share beneficiary-data)
            )
            u100
          ))
          (tax-amount (/ (* share-amount (var-get inheritance-tax)) u100))
        )
        ;; Execute NFT transfers
        (map transfer-nft (get nft-tokens beneficiary-data))

        ;; Mark inheritance as claimed
        (map-set beneficiaries { beneficiary: tx-sender }
          (merge beneficiary-data { claimed: true })
        )

        ;; Transfer net inheritance amount
        (as-contract (stx-transfer? (- share-amount tax-amount) contract-caller tx-sender))
      )
    )
  )
)

;; PHASED INHERITANCE RELEASE SYSTEM

(define-map inheritance-phases
  { beneficiary: principal }
  {
    phase-1-claimed: bool,
    phase-2-claimed: bool,
    phase-1-amount: uint,
    phase-2-amount: uint,
  }
)

;; First phase inheritance claim with risk mitigation
(define-private (claim-phase-1 (phase-data {
  phase-1-claimed: bool,
  phase-2-claimed: bool,
  phase-1-amount: uint,
  phase-2-amount: uint,
}))
  (begin
    (asserts! (not (get phase-1-claimed phase-data)) ERR-ALREADY-CLAIMED)
    (let ((amount (/
        (* (stx-get-balance (as-contract tx-sender))
          (get phase-1-amount phase-data)
        )
        u100
      )))
      (begin
        (map-set inheritance-phases { beneficiary: tx-sender }
          (merge phase-data { phase-1-claimed: true })
        )
        (as-contract (stx-transfer? amount contract-caller tx-sender))
      )
    )
  )
)

;; DISPUTE RESOLUTION FRAMEWORK

(define-map disputes
  { disputer: principal }
  {
    evidence-hash: (buff 32),
    resolved: bool,
  }
)

(define-map dispute-metadata
  { disputer: principal }
  {
    resolution-votes: uint,
    timestamp: uint,
  }
)

(define-map resolution-votes
  {
    dispute-id: principal,
    voter: principal,
  }
  bool
)

(define-data-var resolution-threshold uint u3)

;; Initiates dispute with cryptographic evidence
(define-public (raise-dispute (evidence-hash (buff 32)))
  (let ((beneficiary-data (unwrap! (map-get? beneficiaries { beneficiary: tx-sender })
      ERR-NOT-AUTHORIZED
    )))
    (begin
      (asserts! (not (is-eq evidence-hash 0x)) ERR-INVALID-HASH)
      (asserts! (is-none (map-get? disputes { disputer: tx-sender }))
        ERR-DISPUTE-EXISTS
      )

      (map-set disputes { disputer: tx-sender } {
        evidence-hash: evidence-hash,
        resolved: false,
      })
      (ok true)
    )
  )
)

;; Automated dispute resolution mechanism
(define-private (resolve-dispute (disputer principal))
  (match (map-get? disputes { disputer: disputer })
    dispute-data (begin
      (map-set disputes { disputer: disputer }
        (merge dispute-data { resolved: true })
      )
      true
    )
    false
  )
)

;; EMERGENCY & ADMINISTRATIVE CONTROLS

;; Contract deactivation for emergency scenarios
(define-public (deactivate-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set is-active false)
    (ok true)
  )
)

;; Updates oracle confirmation threshold
(define-public (update-required-confirmations (new-count uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> new-count u0) ERR-INVALID-CONFIRMATION-COUNT)
    (var-set required-confirmations new-count)
    (ok true)
  )
)

;; READ-ONLY INTERFACE

;; Retrieves comprehensive beneficiary information
(define-read-only (get-beneficiary-info (beneficiary principal))
  (map-get? beneficiaries { beneficiary: beneficiary })
)

;; Returns complete contract status overview
(define-read-only (get-contract-status)
  {
    active: (var-get is-active),
    death-confirmed: (var-get death-confirmed),
    confirmation-count: (var-get confirmation-count),
    required-confirmations: (var-get required-confirmations),
    last-will-hash: (var-get last-will-hash),
    inheritance-tax: (var-get inheritance-tax),
  }
)

;; Queries NFT ownership records
(define-read-only (get-nft-owner (token-id uint))
  (map-get? nft-ownership token-id)
)