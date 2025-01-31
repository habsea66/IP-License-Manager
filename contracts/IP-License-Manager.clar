;; Intellectual Property (IP) Licensing Contract

(define-data-var total-licenses uint u0)

;; Represents an individual license with an owner and expiration block.
(define-map licenses
  { license-id: uint }
  { owner: principal, expiry-block: uint })

;; Constants for events
(define-constant EVENT_LICENSE_ISSUED "license_issued")
(define-constant EVENT_LICENSE_TRANSFERRED "license_transferred")
(define-constant EVENT_LICENSE_RENEWED "license_renewed")

;; Error codes
(define-constant ERR_LICENSE_EXISTS u100)
(define-constant ERR_LICENSE_NOT_FOUND u101)
(define-constant ERR_UNAUTHORIZED u103)
(define-constant ERR_INVALID_EXPIRY u104)
(define-constant ERR_INVALID_LICENSE_ID u105)

;; Helper function to validate license-id
(define-private (validate-license-id (license-id uint))
  (and (> license-id u0) (<= license-id u1000000)))

;; Helper function to validate expiry-block
(define-private (validate-expiry-block (expiry-block uint))
  (> expiry-block stacks-block-height))

;; Issue a new license
(define-public (issue-license (license-id uint) (owner principal) (expiry-block uint))
  (let
    ((checked-owner owner)
     (checked-expiry (if (> expiry-block u0) expiry-block u0)))
    (begin
      (asserts! (is-eq tx-sender contract-caller) (err ERR_UNAUTHORIZED))
      (asserts! (validate-license-id license-id) (err ERR_INVALID_LICENSE_ID))
      (asserts! (validate-expiry-block expiry-block) (err ERR_INVALID_EXPIRY))
      (asserts! (is-none (map-get? licenses { license-id: license-id })) (err ERR_LICENSE_EXISTS))
      (asserts! (not (is-eq checked-owner 'SP000000000000000000002Q6VF78)) (err ERR_UNAUTHORIZED))
      (map-set licenses { license-id: license-id } { owner: checked-owner, expiry-block: checked-expiry })
      (var-set total-licenses (+ (var-get total-licenses) u1))
      (print { event: EVENT_LICENSE_ISSUED, license-id: license-id, owner: checked-owner, expiry-block: checked-expiry })
      (ok license-id)
    )))

;; Transfer an existing license
(define-public (transfer-license (license-id uint) (new-owner principal))
  (let
    (
      (license-data (unwrap! (map-get? licenses { license-id: license-id }) (err ERR_LICENSE_NOT_FOUND)))
      (checked-owner new-owner)
    )
    (begin
      (asserts! (validate-license-id license-id) (err ERR_INVALID_LICENSE_ID))
      (asserts! (is-eq tx-sender (get owner license-data)) (err ERR_UNAUTHORIZED))
      (asserts! (not (is-eq checked-owner 'SP000000000000000000002Q6VF78)) (err ERR_UNAUTHORIZED))
      (map-set licenses { license-id: license-id } 
        { owner: checked-owner, expiry-block: (get expiry-block license-data) })
      (print { event: EVENT_LICENSE_TRANSFERRED, license-id: license-id, new-owner: checked-owner })
      (ok license-id)
    )
  ))

;; Renew an existing license
(define-public (renew-license (license-id uint) (new-expiry-block uint))
  (let
    (
      (license-data (unwrap! (map-get? licenses { license-id: license-id }) (err ERR_LICENSE_NOT_FOUND)))
    )
    (begin
      (asserts! (validate-license-id license-id) (err ERR_INVALID_LICENSE_ID))
      (asserts! (validate-expiry-block new-expiry-block) (err ERR_INVALID_EXPIRY))
      (asserts! (is-eq tx-sender (get owner license-data)) (err ERR_UNAUTHORIZED))
      (asserts! (> new-expiry-block (get expiry-block license-data)) (err ERR_INVALID_EXPIRY))
      (map-set licenses { license-id: license-id }
        { owner: (get owner license-data), expiry-block: new-expiry-block })
      (print { event: EVENT_LICENSE_RENEWED, license-id: license-id, new-expiry-block: new-expiry-block })
      (ok license-id)
    )
  ))

;; Get license details
(define-read-only (get-license (license-id uint))
  (map-get? licenses { license-id: license-id }))

;; Get the total number of issued licenses
(define-read-only (get-total-licenses)
  (var-get total-licenses))
