;; Achievement NFT Contract

(define-non-fungible-token achievement-nft uint)

(define-map achievement-data
  { token-id: uint }
  {
    user: principal,
    achievement-type: (string-ascii 50),
    description: (string-utf8 200),
    date: uint
  }
)

(define-data-var achievement-nonce uint u0)

(define-public (mint-achievement-nft (user principal) (achievement-type (string-ascii 50)) (description (string-utf8 200)))
  (let
    ((new-id (+ (var-get achievement-nonce) u1)))
    (try! (nft-mint? achievement-nft new-id user))
    (map-set achievement-data
      { token-id: new-id }
      {
        user: user,
        achievement-type: achievement-type,
        description: description,
        date: block-height
      }
    )
    (var-set achievement-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-achievement-data (token-id uint))
  (map-get? achievement-data { token-id: token-id })
)

