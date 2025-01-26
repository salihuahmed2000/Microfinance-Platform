;; Credit Scoring Contract

(define-map credit-scores principal uint)

(define-constant INITIAL-SCORE u500)
(define-constant MAX-SCORE u1000)
(define-constant MIN-SCORE u0)

(define-public (initialize-credit-score (user principal))
  (match (map-get? credit-scores user)
    score (err u403)
    (map-set credit-scores user INITIAL-SCORE)
  )
  (ok true)
)

(define-public (update-credit-score (user principal) (loan-id uint))
  (let
    ((loan (unwrap! (contract-call? .loan-management get-loan loan-id) (err u404)))
     (current-score (default-to INITIAL-SCORE (map-get? credit-scores user)))
     (total-due (+ (get amount loan) (* (get amount loan) (get interest-rate loan) (get term loan) u1)))
     (repayment-ratio (/ (* (get repaid-amount loan) u100) total-due))
     (score-change (if (>= repayment-ratio u100) u50 (- u0 u50))))
    (asserts! (is-eq (get borrower loan) user) (err u403))
    (asserts! (is-eq (get status loan) "repaid") (err u403))
    (map-set credit-scores
      user
      (max MIN-SCORE (min MAX-SCORE (+ current-score score-change)))
    )
    (ok true)
  )
)

(define-read-only (get-credit-score (user principal))
  (ok (default-to INITIAL-SCORE (map-get? credit-scores user)))
)

