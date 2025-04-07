;; Timepiece Registration Contract
;; Records details of valuable watches

(define-data-var last-timepiece-id uint u0)

;; Define the structure for a timepiece
(define-map timepieces
  { id: uint }
  {
    owner: principal,
    manufacturer: (string-ascii 50),
    model: (string-ascii 100),
    serial-number: (string-ascii 50),
    year: uint,
    registered-at: uint
  }
)

;; Get the next available timepiece ID
(define-read-only (get-next-timepiece-id)
  (var-get last-timepiece-id)
)

;; Register a new timepiece
(define-public (register-timepiece
    (manufacturer (string-ascii 50))
    (model (string-ascii 100))
    (serial-number (string-ascii 50))
    (year uint))
  (let
    (
      (new-id (+ (var-get last-timepiece-id) u1))
    )
    (asserts! (< year (unwrap-panic (get-block-info? time u0))) (err u1))
    (map-insert timepieces
      { id: new-id }
      {
        owner: tx-sender,
        manufacturer: manufacturer,
        model: model,
        serial-number: serial-number,
        year: year,
        registered-at: (unwrap-panic (get-block-info? time u0))
      }
    )
    (var-set last-timepiece-id new-id)
    (ok new-id)
  )
)

;; Get timepiece details
(define-read-only (get-timepiece (id uint))
  (map-get? timepieces { id: id })
)

;; Transfer ownership of a timepiece
(define-public (transfer-timepiece (id uint) (new-owner principal))
  (let
    (
      (timepiece (unwrap! (map-get? timepieces { id: id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner timepiece)) (err u403))
    (map-set timepieces
      { id: id }
      (merge timepiece { owner: new-owner })
    )
    (ok true)
  )
)

