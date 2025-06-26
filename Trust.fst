module Trust

type node = {
  score:(x: int{x > 0});
  out:list node
}

type pathNode node scorable = | PathNode : n: node -> d: scorable -> pathNode node scorable

module TC = FStar.Tactics.Typeclasses

class scorable (a: Type) = { add:(x: a -> y: a -> a) }

let ( + ) #a {| _: scorable a |} (x: a) (y: a) : a = add x y

module U32 = FStar.UInt32

[@@ FStar.Tactics.Typeclasses.tcinstance]
let unint_score:scorable U32.t = { add = (fun x y -> U32.add_underspec x y) }
