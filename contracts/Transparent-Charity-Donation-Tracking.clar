(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-campaign-inactive (err u105))
(define-constant err-goal-reached (err u106))
(define-constant err-insufficient-funds (err u107))
(define-constant err-campaign-active (err u108))

(define-data-var campaign-nonce uint u0)

(define-map campaigns
  { campaign-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    beneficiary: principal,
    goal: uint,
    raised: uint,
    active: bool,
    created-at: uint,
    created-by: principal
  }
)

(define-map donations
  { campaign-id: uint, donor: principal }
  { amount: uint, timestamp: uint }
)

(define-map campaign-donations
  { campaign-id: uint, donation-index: uint }
  { donor: principal, amount: uint, timestamp: uint }
)

(define-map campaign-donation-count
  { campaign-id: uint }
  { count: uint }
)

(define-map donor-total-donations
  { donor: principal }
  { total: uint }
)

(define-map campaign-withdrawals
  { campaign-id: uint, withdrawal-index: uint }
  { amount: uint, timestamp: uint, withdrawn-by: principal }
)

(define-map campaign-withdrawal-count
  { campaign-id: uint }
  { count: uint }
)

(define-read-only (get-campaign (campaign-id uint))
  (map-get? campaigns { campaign-id: campaign-id })
)

(define-read-only (get-donation (campaign-id uint) (donor principal))
  (map-get? donations { campaign-id: campaign-id, donor: donor })
)

(define-read-only (get-campaign-donation (campaign-id uint) (donation-index uint))
  (map-get? campaign-donations { campaign-id: campaign-id, donation-index: donation-index })
)

(define-read-only (get-campaign-donation-count (campaign-id uint))
  (default-to { count: u0 } (map-get? campaign-donation-count { campaign-id: campaign-id }))
)

(define-read-only (get-donor-total (donor principal))
  (default-to { total: u0 } (map-get? donor-total-donations { donor: donor }))
)

(define-read-only (get-campaign-withdrawal (campaign-id uint) (withdrawal-index uint))
  (map-get? campaign-withdrawals { campaign-id: campaign-id, withdrawal-index: withdrawal-index })
)

(define-read-only (get-campaign-withdrawal-count (campaign-id uint))
  (default-to { count: u0 } (map-get? campaign-withdrawal-count { campaign-id: campaign-id }))
)

(define-read-only (get-current-nonce)
  (var-get campaign-nonce)
)

(define-public (create-campaign (name (string-ascii 100)) (description (string-ascii 500)) (beneficiary principal) (goal uint))
  (let
    (
      (campaign-id (var-get campaign-nonce))
    )
    (asserts! (> goal u0) err-invalid-amount)
    (map-set campaigns
      { campaign-id: campaign-id }
      {
        name: name,
        description: description,
        beneficiary: beneficiary,
        goal: goal,
        raised: u0,
        active: true,
        created-at: stacks-block-height,
        created-by: tx-sender
      }
    )
    (var-set campaign-nonce (+ campaign-id u1))
    (ok campaign-id)
  )
)

(define-public (donate (campaign-id uint) (amount uint))
  (let
    (
      (campaign (unwrap! (get-campaign campaign-id) err-not-found))
      (current-donation (default-to { amount: u0, timestamp: u0 } (get-donation campaign-id tx-sender)))
      (donation-count (get count (get-campaign-donation-count campaign-id)))
      (donor-total (get total (get-donor-total tx-sender)))
    )
    (asserts! (get active campaign) err-campaign-inactive)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { raised: (+ (get raised campaign) amount) })
    )
    (map-set donations
      { campaign-id: campaign-id, donor: tx-sender }
      { amount: (+ (get amount current-donation) amount), timestamp: stacks-block-height }
    )
    (map-set campaign-donations
      { campaign-id: campaign-id, donation-index: donation-count }
      { donor: tx-sender, amount: amount, timestamp: stacks-block-height }
    )
    (map-set campaign-donation-count
      { campaign-id: campaign-id }
      { count: (+ donation-count u1) }
    )
    (map-set donor-total-donations
      { donor: tx-sender }
      { total: (+ donor-total amount) }
    )
    (ok true)
  )
)

(define-public (withdraw (campaign-id uint) (amount uint))
  (let
    (
      (campaign (unwrap! (get-campaign campaign-id) err-not-found))
      (withdrawal-count (get count (get-campaign-withdrawal-count campaign-id)))
    )
    (asserts! (is-eq tx-sender (get beneficiary campaign)) err-unauthorized)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= amount (get raised campaign)) err-insufficient-funds)
    (try! (as-contract (stx-transfer? amount tx-sender (get beneficiary campaign))))
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { raised: (- (get raised campaign) amount) })
    )
    (map-set campaign-withdrawals
      { campaign-id: campaign-id, withdrawal-index: withdrawal-count }
      { amount: amount, timestamp: stacks-block-height, withdrawn-by: tx-sender }
    )
    (map-set campaign-withdrawal-count
      { campaign-id: campaign-id }
      { count: (+ withdrawal-count u1) }
    )
    (ok true)
  )
)

(define-public (toggle-campaign-status (campaign-id uint))
  (let
    (
      (campaign (unwrap! (get-campaign campaign-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get created-by campaign)) err-unauthorized)
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { active: (not (get active campaign)) })
    )
    (ok true)
  )
)

(define-public (update-campaign-goal (campaign-id uint) (new-goal uint))
  (let
    (
      (campaign (unwrap! (get-campaign campaign-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get created-by campaign)) err-unauthorized)
    (asserts! (> new-goal u0) err-invalid-amount)
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { goal: new-goal })
    )
    (ok true)
  )
)

