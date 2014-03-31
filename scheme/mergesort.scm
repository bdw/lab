
(define (merge a b)
  ; recursive merge using cond
  (cond ((and (pair? a) (pair? b))
          (if (< (car a) (car b))
              ; this is not a proper tail-recursion
              ; but it does give the right order without reversing
              (cons (car a) (merge (cdr a) b))
              (cons (car b) (merge a (cdr b)))))
         ((pair? a) a)
         (else b)))

(define (prepare a-list)
  ; split the list into one-item sublists
  (do ((l a-list (cdr l)) ; walk over our list
       ; construct the list-of-lists
       (a '() (cons (list (car l)) a)))
      ; return it if we're done
       ((null? l) a)))

(define (merge-step work-list done-list)
  ; this isn't very pretty i admit, but the idea is simple
  (if (null? work-list) ; done with our current 'level of work
      (if (null? done-list) '() ; if we have nothing, return nothing
          (if (null? (cdr done-list)) ; single item? 
              (car done-list) ; return it
              (merge-step done-list '()))) ; otherwise continue anew
      (if (null? (cdr work-list))  ; single item one the work-list?
          ; add it to the 'new work list' and continue anew
          (merge-step (cons (car work-list) done-list) '()) 
          (let ((a (car work-list)) ; take two items
                (b (car (cdr work-list)))
                (rest-list (cdr (cdr work-list)))) ; and the rest of the list
            (merge-step rest-list (cons (merge a b) done-list)))))) ; continue 

(define (mergesort a-list)
  (merge-step (prepare a-list) '()))
