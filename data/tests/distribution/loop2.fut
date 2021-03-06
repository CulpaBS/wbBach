-- More tricky variant of loop0.fut where expanding the initial merge
-- parameter values is not so simple.
--
-- ==
--
-- input {
--   [[[1,7],[9,4],[8,6]],
--    [[1,0],[6,4],[1,6]]]
-- }
-- output {
--   [[19, 24],
--    [9, 10]]
-- }
--
-- structure distributed { Map/Loop 0 }

fun [[int,k],n] main([[[int,k],m],n] a) =
  map(fn [int,k] ([[int,k],m] a_r) =>
        let acc = a_r[0] in
        loop(acc) = for i < m do
          zipWith(+, acc, a_r[i]) in
        acc
     , a)
