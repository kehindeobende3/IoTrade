;; IoT Data Token Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

(define-data-var token-id-nonce uint u0)

(define-non-fungible-token iot-data-token uint)

(define-map token-metadata
  { token-id: uint }
  {
    owner: principal,
    device-id: (string-ascii 64),
    data-type: (string-ascii 32),
    ipfs-hash: (string-ascii 64),
    timestamp: uint,
    price: uint
  }
)

(define-public (mint (device-id (string-ascii 64)) (data-type (string-ascii 32)) (ipfs-hash (string-ascii 64)) (price uint))
  (let
    (
      (token-id (var-get token-id-nonce))
      (owner tx-sender)
    )
    (try! (nft-mint? iot-data-token token-id owner))
    (map-set token-metadata
      { token-id: token-id }
      {
        owner: owner,
        device-id: device-id,
        data-type: data-type,
        ipfs-hash: ipfs-hash,
        timestamp: block-height,
        price: price
      }
    )
    (var-set token-id-nonce (+ token-id u1))
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? iot-data-token token-id) (err u404))) (err u401))
    (try! (nft-transfer? iot-data-token token-id tx-sender recipient))
    (ok true)
  )
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id })
)

(define-public (update-price (token-id uint) (new-price uint))
  (let
    (
      (token (unwrap! (map-get? token-metadata { token-id: token-id }) (err u404)))
    )
    (asserts! (is-eq (get owner token) tx-sender) (err u401))
    (ok (map-set token-metadata
      { token-id: token-id }
      (merge token { price: new-price })
    ))
  )
)

