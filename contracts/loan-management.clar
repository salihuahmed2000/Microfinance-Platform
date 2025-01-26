;; Loan Management Contract

(define-map loans
  { loan-id: uint }
  {
    borrower: principal,
    lender: principal,
    amount: uint,
    interest-rate: uint,
    term: uint,
    start-date: uint,
    status: (string-ascii 20),
    repaid-amount: uint
  }
)

(define-map user-loans
  { user: principal }
  (list 100 uint)
)

(define-data-var loan-nonce uint u0)

(define-public (create-loan (amount uint) (interest-rate uint) (term uint))
  (let
    ((new-id (+ (var-get loan-nonce) u1))
     (borrower-loans (default-to (list) (map-get? user-loans { user: tx-sender }))))
    (map-set loans
      { loan-id: new-id }
      {
        borrower: tx-sender,
        lender: tx-sender,
        amount: amount,
        interest-rate: interest-rate,
        term: term,
        start-date: block-height,
        status: "pending",
        repaid-amount: u0
      }
    )
    (map-set user-loans
      { user: tx-sender }
      (unwrap! (as-max-len? (append borrower-loans new-id) u100) (err u500))
    )
    (var-set loan-nonce new-id)
    (ok new-id)
  )
)

(define-public (fund-loan (loan-id uint))
  (let
    ((loan (unwrap! (map-get? loans { loan-id: loan-id }) (err u404)))
     (lender-loans (default-to (list) (map-get? user-loans { user: tx-sender }))))
    (asserts! (is-eq (get status loan) "pending") (err u403))
    (try! (stx-transfer? (get amount loan) tx-sender (get borrower loan)))
    (map-set loans
      { loan-id: loan-id }
      (merge loan { lender: tx-sender, status: "active" })
    )
    (map-set user-loans
      { user: tx-sender }
      (unwrap! (as-max-len? (append lender-loans loan-id) u100) (err u500))
    )
    (ok true)
  )
)

(define-public (repay-loan (loan-id uint) (repayment-amount uint))
  (let
    ((loan (unwrap! (map-get? loans { loan-id: loan-id }) (err u404)))
     (new-repaid-amount (+ (get repaid-amount loan) repayment-amount))
     (total-due (+ (get amount loan) (* (get amount loan) (get interest-rate loan) (get term loan) u1))))
    (asserts! (is-eq tx-sender (get borrower loan)) (err u403))
    (asserts! (is-eq (get status loan) "active") (err u403))
    (try! (stx-transfer? repayment-amount tx-sender (get lender loan)))
    (map-set loans
      { loan-id: loan-id }
      (merge loan
        {
          repaid-amount: new-repaid-amount,
          status: (if (>= new-repaid-amount total-due) "repaid" (get status loan))
        }
      )
    )
    (ok true)
  )
)

(define-read-only (get-loan (loan-id uint))
  (map-get? loans { loan-id: loan-id })
)

(define-read-only (get-user-loans (user principal))
  (map-get? user-loans { user: user })
)

