  $ cat <<EOF | ./main.exe '(X\/~X)->(~~X->X)'
  > Intros
  > Intros
  > NotIntros
  > Contradiction
  > Qed
  === Current state ===
  Assumptions:
  
  Current target:
  ((X \/ ~X) -> (~~X -> X))
  > === Current state ===
  Assumptions:
  0: (X \/ ~X)
  
  Current target:
  (~~X -> X)
  > === Current state ===
  Assumptions:
  0: ~~X
  1: (X \/ ~X)
  
  Current target:
  X
  > === Current state ===
  Assumptions:
  0: ~X
  1: ~~X
  2: (X \/ ~X)
  
  Current target:
  False
  > Proof completed!

  $ cat <<EOF | ./main.exe 'X->~~X'
  > Intros
  > NotIntrosIntros
  > Contradiction
  > Qed
  === Current state ===
  Assumptions:
  
  Current target:
  (X -> ~~X)
  > === Current state ===
  Assumptions:
  0: X
  
  Current target:
  ~~X
  > Unknown tactic: NotIntrosIntros
  === Current state ===
  Assumptions:
  0: X
  
  Current target:
  ~~X
  > no contradiction in assumptions
  === Current state ===
  Assumptions:
  0: X
  
  Current target:
  ~~X
  > proof incomplete
  === Current state ===
  Assumptions:
  0: X
  
  Current target:
  ~~X
  > Interrupted.
  Proof incomplete.
  [1]

  $ cat <<EOF | ./main.exe '(X/\~X)->Y'
  > Intros
  > AndElim
  > Contradiction
  > Qed
  === Current state ===
  Assumptions:
  
  Current target:
  ((X /\ ~X) -> Y)
  > === Current state ===
  Assumptions:
  0: (X /\ ~X)
  
  Current target:
  Y
  > === Current state ===
  Assumptions:
  0: X
  1: ~X
  
  Current target:
  Y
  > Proof completed!

  $ cat <<EOF | ./main.exe '(X/\~X)->Y'
  > Intros
  > AndElim
  > Contradiction
  > Qed
  === Current state ===
  Assumptions:
  
  Current target:
  ((X /\ ~X) -> Y)
  > === Current state ===
  Assumptions:
  0: (X /\ ~X)
  
  Current target:
  Y
  > === Current state ===
  Assumptions:
  0: X
  1: ~X
  
  Current target:
  Y
  > Proof completed!

  $ cat <<EOF | ./main.exe '(x->y->z)<->(x/\y->z)'
  > EquivIntro
  > Intros
  > Intros
  > AndElim
  > Apply
  > Apply
  > Axiom
  > Intros
  > Intros
  > Intros
  > Axiom
  > Qed
  === Current state ===
  Assumptions:
  
  Current target:
  ((x -> (y -> z)) <-> ((x /\ y) -> z))
  > === Current state ===
  Assumptions:
  
  Current target:
  ((x -> (y -> z)) -> ((x /\ y) -> z))
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: (x -> (y -> z))
  
  Current target:
  ((x /\ y) -> z)
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: (x /\ y)
  1: (x -> (y -> z))
  
  Current target:
  z
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: (x -> (y -> z))
  1: x
  2: y
  
  Current target:
  z
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: y
  1: x
  2: (y -> z)
  
  Current target:
  z
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: z
  1: x
  2: y
  
  Current target:
  z
  
  Remaining targets: 1
  > === Current state ===
  Assumptions:
  0: z
  1: x
  2: y
  
  Current target:
  (((x /\ y) -> z) -> (x -> (y -> z)))
  > === Current state ===
  Assumptions:
  0: ((x /\ y) -> z)
  1: z
  2: x
  3: y
  
  Current target:
  (x -> (y -> z))
  > === Current state ===
  Assumptions:
  0: x
  1: ((x /\ y) -> z)
  2: z
  3: x
  4: y
  
  Current target:
  (y -> z)
  > === Current state ===
  Assumptions:
  0: y
  1: x
  2: ((x /\ y) -> z)
  3: z
  4: x
  5: y
  
  Current target:
  z
  > Proof completed!
