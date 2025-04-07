;; Manufacturer Verification Contract
;; Validates legitimate production

;; Contract owner
(define-constant contract-owner tx-sender)

;; Define the structure for a manufacturer
(define-map verified-manufacturers
  { name: (string-ascii 50) }
  {
    verified: bool,
    verification-date: uint,
    website: (string-ascii 100),
    verified-by: principal
  }
)

;; Check if a manufacturer is verified
(define-read-only (is-manufacturer-verified (name (string-ascii 50)))
  (default-to false (get verified (map-get? verified-manufacturers { name: name })))
)

;; Add a new manufacturer (only contract owner can do this)
(define-public (add-manufacturer
    (name (string-ascii 50))
    (website (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (map-insert verified-manufacturers
      { name: name }
      {
        verified: true,
        verification-date: (unwrap-panic (get-block-info? time u0)),
        website: website,
        verified-by: tx-sender
      }
    )
    (ok true)
  )
)

;; Revoke manufacturer verification
(define-public (revoke-manufacturer (name (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (map-delete verified-manufacturers { name: name })
    (ok true)
  )
)

;; Get manufacturer details
(define-read-only (get-manufacturer (name (string-ascii 50)))
  (map-get? verified-manufacturers { name: name })
)

