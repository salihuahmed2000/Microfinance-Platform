;; Loan NFT Contract

(define-non-fungible-token loan-nft uint)

(define-map loan-nft-data
  { token-id: uint }
  {
    loan-id: uint,
    borrower: principal,
    lender: principal,
    amount: uint,
    interest-rate: uint,
    term: uint
  }
)

(define-public (mint-loan-nft (loan-id uint))
  (let
    ((loan (unwrap! (contract-call? .loan-management get-loan loan-id) (err u404))))
    (asserts! (is-eq (get status loan) "active") (err u403))
    (try! (nft-mint? loan-nft loan-id (get lender loan)))
    (map-set loan-nft-data
      { token-id: loan-id }
      {
        loan-id: loan-id,
        borrower: (get borrower loan),
        lender: (get lender loan),
        amount: (get amount loan),
        interest-rate: (get interest-rate loan),
        term: (get term loan)
      }
    )
    (ok true)
  )
)

(define-public (transfer-loan-nft (token-id uint) (recipient principal))
  (let
    ((loan (unwrap! (contract-call? .loan-management get-loan token-id) (err u404))))
    (asserts! (is-eq (get status loan) "active") (err u403))
    (try! (nft-transfer? loan-nft token-id tx-sender recipient))
    (contract-call? .loan-management update-loan-lender token-id recipient)
  )
)

(define-read-only (get-loan-nft-data (token-id uint))
  (map-get? loan-nft-data { token-id: token-id })
)

