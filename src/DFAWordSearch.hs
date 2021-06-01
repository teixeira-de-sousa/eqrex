module DFAWordSearch where

import Language.HaLex.Dfa (Dfa (..))
import Language.HaLex.Minimize (minimizeDfa)

data LOL a = LOL [a]
   deriving Eq
instance Ord a => Ord (LOL a) where
   LOL x1 <= LOL x2 = (length x1, x1) <= (length x2, x2)
instance Show a => Show (LOL a) where
   show (LOL a) = show a

infixl 6 \/
(\/) :: Ord a => [a] -> [a] -> [a]
[] \/ ys = ys
xs \/ [] = xs
xs@(x:xt) \/ ys@(y:yt) = case compare x y of
   LT -> x : xt\/ys
   EQ -> x : xt\/yt
   GT -> y : xs\/yt

unionWordSearch :: (Eq sy, Eq st, Ord sy, Ord st) => Dfa st sy -> [[sy]]
unionWordSearch fulldfa =
   [str | (LOL str,bool) <- uWS dfa init (LOL []), bool]
      where
         dfa@(Dfa voc sts init fin trans) = minimizeDfa fulldfa
         trash = [ x | x <- sts, not (elem x fin), and [x == (trans x v) | v <- voc]]
         uWS dfa st (LOL s)
            | elem st trash = []
            | otherwise = (LOL s, elem st fin) : foldr (\/) [] [uWS dfa (trans st v) (LOL (s++[v])) | v <- voc]