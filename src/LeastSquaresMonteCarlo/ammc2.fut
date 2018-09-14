--
-- Based on implementation in R by Rolf Poulsen, Martin Elsman
--
-- See https://github.com/HIPERFIT/recipes/blob/master/src/LeastSquaresMonteCarlo.R
--
-- Longstaff and Schwartz American option pricing based on linear regression
--

import "/futlib/math"
import "lib/github.com/diku-dk/linalg/linalg"

module A = import "/futlib/array"
module M = mk_linalg f64

type real = f64

let strike = 1.1f64
let payoffFun (s:real) : real = f64.max (strike-s) 0f64

let mean [n] (xs:[n]f64) = reduce (+) 0f64 xs / r64(n)

let lsmc [paths] [steps] (S:[paths][steps]real) (r:real) =
  let disc = map (\s -> f64.exp(r*r64(-(s+1)))) (iota (steps-1))
  let P = map (\j ->
               map (\i ->
                    if i < steps-1 then 0f64
                    else payoffFun(S[j,i])
                   ) (iota steps)
              ) (iota paths)

  -- Now do LSM within a loop
  let (P,_) = unsafe
    loop (P,h) = (P,steps-2) while h >= 1 do
     let jpick = map (\j -> (j,payoffFun(S[j,h]) > 0f64)) (iota paths)
     let pickedpaths = map (\(x,_) -> x) (filter (\(_,b) -> b) jpick)
     let numpicked = length pickedpaths
     let Y = map (\j ->
                  let xs = map (\i -> disc[i]*P[j,h+i]) (iota (steps-h))
                  in reduce (+) 0f64 xs) pickedpaths
     let X = map (\j ->
                  let dummy = S[j,h]
                  in [1f64, dummy, dummy*dummy]) pickedpaths
     let Xt = A.transpose X
     let b = M.matvecmul_row (M.inv (M.matmul Xt X)) (M.matvecmul_row Xt Y)

     let payoffs = map (\i ->
                        let j = pickedpaths[i]
                        in payoffFun(S[j,h])) (iota numpicked)

     let cs = map (\i -> let j = pickedpaths[i]
                         let a = [1f64, S[j,h], S[j,h]*S[j,h]]
                         in M.dotprod a b) (iota numpicked)

     -- let (P,_) =
     --    loop (P,i) = (P,0) while i < numpicked do
     --      let j = pickedpaths[i]
     --      let P = if cs[i] < payoffs[i] then
     --                 P with [j] <- (replicate steps 0f64)
     --              else P
     --      let P = if cs[i] < payoffs[i] then P with [j,h] <- payoffs[i]
     --              else P
     --      in (P,i+1)

     let G = map (\ik ->
                  let i = ik / steps
                  let k = ik % steps
                  let j = pickedpaths[i]
                  let jk = steps*j+k
                  in if cs[i] < payoffs[i] then
                       if k==h && 1 <= k && k <= steps-2 then (jk,payoffs[i])
                       else (jk,0.0f64)
                     else (-1,0.0f64)) (iota (steps*numpicked))
     let (inds,vals) = unzip G
     let M = paths * steps
     let P : [M]real = scatter (copy(flatten P)) inds vals
     let P : [paths][steps]real = unflatten paths steps P
     in (P,h-1)
  let Z = map (\j ->
               let xs = map (\i -> disc[i]*P[j,i+1]) (iota (steps-1))
               in reduce (+) 0f64 xs) (iota paths)
  in mean Z

-- Paper Example 1

let main() =
  let EXAMPLE = [ [1.00, 1.09, 1.08, 1.34],
                  [1.00, 1.16, 1.26, 1.54],
                  [1.00, 1.22, 1.07, 1.03],
                  [1.00, 0.93, 0.97, 0.92],
                  [1.00, 1.11, 1.56, 1.52],
                  [1.00, 0.76, 0.77, 0.90],
                  [1.00, 0.92, 0.84, 1.01],
                  [1.00, 0.88, 1.22, 1.34] ]
  let rate = 0.06
  let res = lsmc EXAMPLE rate
in res

-- Expected result: 0.1144343 (see paper)
