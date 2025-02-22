;; CharityDAO: A community-governed charitable contribution token

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-recipient (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-unauthorized (err u105))

;; Token configuration
(define-fungible-token charity-dao)
(define-data-var token-name (string-ascii 32) "CharityDAO")
(define-data-var token-symbol (string-ascii 10) "CDAO")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Charity configuration
(define-data-var charity-percentage uint u5) ;; 0.5% charity contribution
(define-data-var charity-wallet principal contract-owner)

;; Governance
(define-map votes
  { proposal: uint }
  { vote-count: uint }
)

;; Read-only functions
(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance charity-dao account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply charity-dao))
)

(define-read-only (get-charity-wallet)
  (ok (var-get charity-wallet))
)

(define-read-only (get-charity-percentage)
  (ok (var-get charity-percentage))
)

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (let
    (
      (charity-amount (/ (* amount (var-get charity-percentage)) u1000))
      (recipient-amount (- amount charity-amount))
      (charity-addr (var-get charity-wallet))
    )
    (begin
      (asserts! (is-eq tx-sender sender) err-not-token-owner)
      (asserts! (> amount u0) err-invalid-amount)
      (asserts! (not (is-eq recipient charity-addr)) err-invalid-recipient)
      (try! (ft-transfer? charity-dao charity-amount sender charity-addr))
      (try! (ft-transfer? charity-dao recipient-amount sender recipient))
      (ok true)
    )
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-valid-recipient recipient) err-invalid-recipient)
    (ft-mint? charity-dao amount recipient)
  )
)

;; Governance functions
(define-public (submit-proposal (proposal-id uint))
  (begin
    (asserts! (> (ft-get-balance charity-dao tx-sender) u0) err-unauthorized)
    (asserts! (is-valid-proposal-id proposal-id) err-invalid-amount)
    (map-set votes { proposal: proposal-id } { vote-count: u0 })
    (ok true)
  )
)

(define-public (vote (proposal-id uint))
  (let
    (
      (current-votes (default-to { vote-count: u0 } (map-get? votes { proposal: proposal-id })))
    )
    (begin
      (asserts! (> (ft-get-balance charity-dao tx-sender) u0) err-unauthorized)
      (asserts! (is-valid-proposal-id proposal-id) err-invalid-amount)
      (map-set votes
        { proposal: proposal-id }
        { vote-count: (+ u1 (get vote-count current-votes)) }
      )
      (ok true)
    )
  )
)

;; Admin functions
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-uri new-uri) err-invalid-amount)
    (ok (var-set token-uri new-uri))
  )
)

(define-public (set-charity-wallet (new-wallet principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-wallet new-wallet) err-invalid-recipient)
    (ok (var-set charity-wallet new-wallet))
  )
)

(define-public (set-charity-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-percentage u1000) err-invalid-amount) ;; Max 100%
    (ok (var-set charity-percentage new-percentage))
  )
)

;; Helper functions
(define-private (is-valid-recipient (recipient principal))
  (begin
    (is-eq recipient contract-owner)
  )
)

(define-private (is-valid-proposal-id (proposal-id uint))
  (begin
    (> proposal-id u0)
  )
)

(define-private (is-valid-uri (uri (optional (string-utf8 256))))
  (begin
    (is-some uri)
  )
)

(define-private (is-valid-wallet (wallet principal))
  (begin
    (is-eq wallet contract-owner)
  )
)