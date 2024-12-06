;; NanosatelliteNFT Contract

(define-non-fungible-token nanosatellite uint)

(define-data-var last-satellite-id uint u0)

(define-map satellite-data
  { satellite-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    orbital-parameters: (string-utf8 256),
    capabilities: (list 10 (string-ascii 64))
  }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

(define-public (mint-satellite (name (string-ascii 64)) (orbital-parameters (string-utf8 256)) (capabilities (list 10 (string-ascii 64))))
  (let
    (
      (new-satellite-id (+ (var-get last-satellite-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? nanosatellite new-satellite-id tx-sender))
    (map-set satellite-data
      { satellite-id: new-satellite-id }
      {
        owner: tx-sender,
        name: name,
        orbital-parameters: orbital-parameters,
        capabilities: capabilities
      }
    )
    (var-set last-satellite-id new-satellite-id)
    (ok new-satellite-id)
  )
)

(define-public (transfer-satellite (satellite-id uint) (recipient principal))
  (let
    (
      (owner (unwrap! (nft-get-owner? nanosatellite satellite-id) err-not-found))
    )
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (try! (nft-transfer? nanosatellite satellite-id tx-sender recipient))
    (ok (map-set satellite-data
      { satellite-id: satellite-id }
      (merge (unwrap! (map-get? satellite-data { satellite-id: satellite-id }) err-not-found)
             { owner: recipient })
    ))
  )
)

(define-read-only (get-satellite-info (satellite-id uint))
  (ok (unwrap! (map-get? satellite-data { satellite-id: satellite-id }) err-not-found))
)

(define-read-only (get-satellite-owner (satellite-id uint))
  (ok (nft-get-owner? nanosatellite satellite-id))
)

