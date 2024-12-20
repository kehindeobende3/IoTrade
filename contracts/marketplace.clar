;; Marketplace Contract

(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

(define-map sales
  { token-id: uint }
  { seller: principal, price: uint }
)

(define-public (list-for-sale (token-id uint) (price uint))
  (ok (map-set sales { token-id: token-id } { seller: tx-sender, price: price }))
)

(define-public (cancel-sale (token-id uint))
  (let
    (
      (sale (unwrap! (map-get? sales { token-id: token-id }) (err u404)))
    )
    (asserts! (is-eq (get seller sale) tx-sender) (err u401))
    (map-delete sales { token-id: token-id })
    (ok true)
  )
)

(define-public (buy (token-id uint))
  (let
    (
      (sale (unwrap! (map-get? sales { token-id: token-id }) (err u404)))
      (price (get price sale))
      (seller (get seller sale))
    )
    (try! (stx-transfer? price tx-sender seller))
    (map-delete sales { token-id: token-id })
    (ok true)
  )
)

(define-read-only (get-sale (token-id uint))
  (map-get? sales { token-id: token-id })
)

