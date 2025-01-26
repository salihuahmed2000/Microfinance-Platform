;; Fiat Gateway Contract

(define-map fiat-balances principal uint)

(define-public (deposit-fiat (amount uint))
  (let
    ((current-balance (default-to u0 (map-get? fiat-balances tx-sender))))
    (map-set fiat-balances tx-sender (+ current-balance amount))
    (ok true)
  )
)

(define-public (withdraw-fiat (amount uint))
  (let
    ((current-balance (default-to u0 (map-get? fiat-balances tx-sender))))
    (asserts! (>= current-balance amount) (err u401))
    (map-set fiat-balances tx-sender (- current-balance amount))
    (ok true)
  )
)

(define-public (convert-fiat-to-stx (amount uint))
  (let
    ((fiat-balance (default-to u0 (map-get? fiat-balances tx-sender))))
    (asserts! (>= fiat-balance amount) (err u401))
    (map-set fiat-balances tx-sender (- fiat-balance amount))
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (ok true)
  )
)

(define-public (convert-stx-to-fiat (amount uint))
  (let
    ((stx-balance (stx-get-balance tx-sender)))
    (asserts! (>= stx-balance amount) (err u401))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set fiat-balances
      tx-sender
      (+ (default-to u0 (map-get? fiat-balances tx-sender)) amount)
    )
    (ok true)
  )
)

(define-read-only (get-fiat-balance (user principal))
  (ok (default-to u0 (map-get? fiat-balances user)))
)

