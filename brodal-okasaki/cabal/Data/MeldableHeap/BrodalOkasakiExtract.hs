module Data.MeldableHeap.BrodalOkasakiExtract where

import qualified Prelude

type Sig a = a
  -- singleton inductive, whose constructor was exist
  
type ORDER a =
  a -> a -> Prelude.Bool
  -- singleton inductive, whose constructor was Order
  
fold_right :: (a2 -> a1 -> a1) -> a1 -> ([] a2) -> a1
fold_right f a0 l =
  case l of
    [] -> a0
    (:) b t -> f b (fold_right f a0 t)

data MINQ a pQ = Minq pQ (a -> pQ -> pQ) (pQ -> Prelude.Maybe a) 
               (pQ -> Prelude.Maybe ((,) a pQ)) (pQ -> [] a) 
               (pQ -> pQ -> pQ)

empty :: (ORDER a1) -> (MINQ a1 a2) -> a2
empty h mINQ =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> empty0

insert :: (ORDER a1) -> (MINQ a1 a2) -> a1 -> a2 -> a2
insert h mINQ x x0 =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> insert0 x x0

findMin :: (ORDER a1) -> (MINQ a1 a2) -> a2 -> Prelude.Maybe a1
findMin h mINQ x =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> findMin0 x

extractMin :: (ORDER a1) -> (MINQ a1 a2) -> a2 -> Prelude.Maybe ((,) a1 a2)
extractMin h mINQ x =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> extractMin0 x

toList :: (ORDER a1) -> (MINQ a1 a2) -> a2 -> [] a1
toList h mINQ x =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> toList0 x

meld :: (ORDER a1) -> (MINQ a1 a2) -> a2 -> a2 -> a2
meld h mINQ x x0 =
  case mINQ of
    Minq empty0 insert0 findMin0 extractMin0 toList0 meld0 -> meld0 x x0

data Tree a n = Node (Root a n) n (Many a n)
data Root a n = Top a (Many a n)
data Many a n = Cil
                | Nons (Tree a n) (Many a n)

rank :: (Tree a1 a2) -> a2
rank x =
  case x of
    Node r0 r m -> r

root :: (Tree a1 a2) -> Root a1 a2
root x =
  case x of
    Node v n m -> v

toListR :: (Root a1 a2) -> ([] a1) -> [] a1
toListR =
  let
    toListT x r =
      case x of
        Node h n t -> toListR0 h (toListM t r)
    toListR0 x r =
      case x of
        Top v t -> toListM t ((:) v r)
    toListM x r =
      case x of
        Cil -> r
        Nons h t -> toListT h (toListM t r)
  in toListR0

link :: (a2 -> a2) -> (ORDER a1) -> (Tree a1 a2) -> (Tree 
        a1 a2) -> Tree a1 a2
link succ o x y =
  case x of
    Node v n p ->
      (case y of
         Node w m q ->
           (case case v of
                   Top p0 m0 -> (case w of
                                   Top q0 m1 -> o p0 q0) of
              Prelude.True -> Node v (succ n) (Nons y p)
              Prelude.False -> Node w (succ m) (Nons x q)))

skewLink :: (a2 -> a2) -> (ORDER a1) -> (Tree a1 a2) -> (Tree 
            a1 a2) -> (Tree a1 a2) -> Tree a1 a2
skewLink succ o x y z =
  case x of
    Node a i p ->
      (case y of
         Node b j q ->
           (case z of
              Node c k r ->
                (case case a of
                        Top p0 m -> (case b of
                                       Top q0 m0 -> o p0 q0) of
                   Prelude.True ->
                     (case case a of
                             Top p0 m -> (case c of
                                            Top q0 m0 -> o p0 q0) of
                        Prelude.True -> Node a (succ j) (Nons y (Nons z Cil))
                        Prelude.False -> Node c (succ k) (Nons x (Nons y r)))
                   Prelude.False ->
                     (case case b of
                             Top p0 m -> (case c of
                                            Top q0 m0 -> o p0 q0) of
                        Prelude.True -> Node b (succ j) (Nons x (Nons z q))
                        Prelude.False -> Node c (succ k) (Nons x (Nons y r))))))

ins :: (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
       a1) -> (Tree a1 a2) -> (Many a1 a2) -> Many 
       a1 a2
ins succ comp o t xs =
  case xs of
    Cil -> Nons t Cil
    Nons y ys ->
      (case comp (rank t) (rank y) of
         Prelude.LT -> Nons t xs
         _ -> ins succ comp o (link succ o t y) ys)

uniqify :: (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
           a1) -> (Many a1 a2) -> Many a1 a2
uniqify succ comp o xs =
  case xs of
    Cil -> Cil
    Nons y ys -> ins succ comp o y ys

meldUniq :: (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
            a1) -> ((,) (Many a1 a2) (Many a1 a2)) -> Many 
            a1 a2
meldUniq succ comp o x =
  case x of
    (,) x0 y ->
      (case x0 of
         Cil -> y
         Nons p ps ->
           (case y of
              Cil -> Nons p ps
              Nons q qs ->
                (case comp (rank p) (rank q) of
                   Prelude.EQ ->
                     ins succ comp o (link succ o p q)
                       (meldUniq succ comp o ((,) ps qs))
                   Prelude.LT -> Nons p
                     (meldUniq succ comp o ((,) ps (Nons q qs)))
                   Prelude.GT -> Nons q
                     (meldUniq succ comp o ((,) (Nons p ps) qs)))))

skewEmpty :: Many a1 a2
skewEmpty =
  Cil

skewInsert :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER
              a1) -> (Root a1 a2) -> (Many a1 a2) -> Many 
              a1 a2
skewInsert zero succ comp o x ys =
  case ys of
    Cil -> Nons (Node x zero Cil) ys
    Nons z1 m ->
      (case m of
         Cil -> Nons (Node x zero Cil) ys
         Nons z2 zr ->
           (case comp (rank z1) (rank z2) of
              Prelude.EQ -> Nons (skewLink succ o (Node x zero Cil) z1 z2) zr
              _ -> Nons (Node x zero Cil) ys))

skewMeld :: (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
            a1) -> (Many a1 a2) -> (Many a1 a2) -> Many 
            a1 a2
skewMeld succ comp o x y =
  meldUniq succ comp o ((,) (uniqify succ comp o x) (uniqify succ comp o y))

getMin :: (ORDER a1) -> (Tree a1 a2) -> (Many a1 a2) -> (,) 
          (Tree a1 a2) (Many a1 a2)
getMin o x xs =
  case xs of
    Cil -> (,) x Cil
    Nons y ys ->
      (case getMin o y ys of
         (,) t ts ->
           (case case root x of
                   Top p m -> (case root t of
                                 Top q m0 -> o p q) of
              Prelude.True -> (,) x xs
              Prelude.False -> (,) t (Nons x ts)))

children :: (Tree a1 a2) -> Many a1 a2
children x =
  case x of
    Node r n c -> c

split :: (Many a1 a2) -> ([] (Root a1 a2)) -> (Many 
         a1 a2) -> (,) (Many a1 a2) ([] (Root a1 a2))
split t x c =
  case c of
    Cil -> (,) t x
    Nons d ds ->
      (case children d of
         Cil -> split t ((:) (root d) x) ds
         Nons t0 m -> split (Nons d t) x ds)

skewExtractMin :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) ->
                  (ORDER a1) -> (Many a1 a2) -> Prelude.Maybe
                  ((,) (Root a1 a2) (Many a1 a2))
skewExtractMin zero succ comp o x =
  case x of
    Cil -> Prelude.Nothing
    Nons y ys -> Prelude.Just
      (case getMin o y ys of
         (,) t0 t ->
           (case t0 of
              Node v n c -> (,) v
                (case split Cil [] c of
                   (,) p q ->
                     fold_right (\x0 x1 -> skewInsert zero succ comp o x0 x1)
                       (skewMeld succ comp o t p) q)))

data BootWrap a n = Empty
                    | Full (Root a n)

type PQ a n = (BootWrap a n)

bootInsert :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER
              a1) -> a1 -> (PQ a1 a2) -> PQ a1 a2
bootInsert zero succ comp o x x0 =
  let x1 = Full (Top x skewEmpty) in
  (case x1 of
     Empty -> x0
     Full r ->
       (case r of
          Top v c ->
            (case x0 of
               Empty -> x1
               Full r0 ->
                 (case r0 of
                    Top w d ->
                      (case o v w of
                         Prelude.True -> Full (Top v
                           (skewInsert zero succ comp o (Top w d) c))
                         Prelude.False -> Full (Top w
                           (skewInsert zero succ comp o (Top v c) d)))))))

bootFindMin :: (ORDER a1) -> (PQ a1 a2) -> Prelude.Maybe a1
bootFindMin o x =
  case x of
    Empty -> Prelude.Nothing
    Full r -> (case r of
                 Top v m -> Prelude.Just v)

bootMeld :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
            a1) -> (PQ a1 a2) -> (PQ a1 a2) -> PQ a1 
            a2
bootMeld zero succ comp o x x0 =
  case x of
    Empty -> x0
    Full r ->
      (case r of
         Top v c ->
           (case x0 of
              Empty -> x
              Full r0 ->
                (case r0 of
                   Top w d ->
                     (case o v w of
                        Prelude.True -> Full (Top v
                          (skewInsert zero succ comp o (Top w d) c))
                        Prelude.False -> Full (Top w
                          (skewInsert zero succ comp o (Top v c) d))))))

bootExtractMin :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) ->
                  (ORDER a1) -> (PQ a1 a2) -> Prelude.Maybe
                  ((,) a1 (PQ a1 a2))
bootExtractMin zero succ comp o x =
  case x of
    Empty -> Prelude.Nothing
    Full r ->
      (case r of
         Top v c -> Prelude.Just ((,) v
           (case skewExtractMin zero succ comp o c of
              Prelude.Just p ->
                (case p of
                   (,) r0 cs ->
                     (case r0 of
                        Top w d -> Full (Top w (skewMeld succ comp o d cs))))
              Prelude.Nothing -> Empty)))

bootEmpty :: (ORDER a1) -> PQ a1 a2
bootEmpty o =
  Empty

bootToList :: (ORDER a1) -> (PQ a1 a2) -> [] a1
bootToList o x =
  case x of
    Empty -> []
    Full y -> toListR y []

bootPQ :: a2 -> (a2 -> a2) -> (a2 -> a2 -> Prelude.Ordering) -> (ORDER 
          a1) -> MINQ a1 (PQ a1 a2)
bootPQ zero succ comp o =
  Minq (bootEmpty o) (\x x0 -> bootInsert zero succ comp o x x0) (\x ->
    bootFindMin o x) (\x -> bootExtractMin zero succ comp o x) (\x ->
    bootToList o x) (\x x0 -> bootMeld zero succ comp o x x0)
