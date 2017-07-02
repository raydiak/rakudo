# This file implements the following set operators:
#   (<)   is a proper subset of (Texas)
#   ⊂     is a proper subset of
#   ⊄     is NOT a proper subset of
#   (>)   is a proper superset of (Texas)
#   ⊃     is a proper superset of
#   ⊅     is NOT a proper superset of

proto sub infix:<<(<)>>($, $ --> Bool:D) is pure {*}
multi sub infix:<<(<)>>(QuantHash:D $a, QuantHash:D $b --> Bool:D) {
    nqp::if(
      nqp::eqaddr(nqp::decont($a),nqp::decont($b)),
      False,                    # X is never a true subset of itself
      nqp::if(
        (my $braw := $b.raw_hash) && nqp::elems($braw),
        nqp::if(
          (my $araw := $a.raw_hash) && nqp::elems($araw),
          nqp::if(
            nqp::islt_i(nqp::elems($araw),nqp::elems($braw))
              && (my $iter := nqp::iterator($araw)),
            nqp::stmts(         # A has fewer elems than B
              nqp::while(
                $iter,
                nqp::unless(
                  nqp::existskey($braw,nqp::iterkey_s(nqp::shift($iter))),
                  return False  # elem in A doesn't exist in B
                )
              ),
              True              # all elems in A exist in B
            ),
            False               # number of elems in B smaller or equal to A
          ),
          True                  # no elems in A, and elems in B
        ),
        False                   # can never have fewer elems in A than in B
      )
    )
}
multi sub infix:<<(<)>>(Map:D $a, Map:D $b --> Bool:D) {
    nqp::if(
      nqp::eqaddr(nqp::decont($a),nqp::decont($b)),
      False,                      # X is never a true subset of itself
      nqp::if(                    # A and B are different
        (my $araw := nqp::getattr(nqp::decont($a),Map,'$!storage'))
          && nqp::elems($araw),
        nqp::if(                  # something in A
          nqp::eqaddr($a.keyof,Str(Any)) && nqp::eqaddr($b.keyof,Str(Any)),
          nqp::if(                # both are normal Maps
            (my $braw := nqp::getattr(nqp::decont($b),Map,'$!storage'))
              && nqp::elems($braw)
              && (my $iter := nqp::iterator($araw)),
            nqp::stmts(           # something to check for in B
              nqp::while(
                $iter,
                nqp::if(
                  nqp::iterval(nqp::shift($iter))
                    || nqp::isfalse(nqp::atkey($braw,nqp::iterkey_s($iter))),
                  return False    # valid elem in A or invalid elem in B
                )
              ),
              True                # no valids in A, valids in B
            ),
            False                 # something in A, nothing in B
          ),
          $a.Set (<) $b.Set       # either is objectHash, so coerce
        ),
        nqp::if(                  # nothing in A
          ($braw := nqp::getattr(nqp::decont($b),Map,'$!storage'))
            && nqp::elems($braw)
            && ($iter := nqp::iterator($braw)),
          nqp::stmts(             # something in B
            nqp::while(
              $iter,
              nqp::if(
                nqp::iterval(nqp::shift($iter)),
                return True       # found valid elem in B
              )
            ),
            False                 # no valid elem in B
          ),
          False                   # nothing in B (nor A)
        )
      )
    )
}
multi sub infix:<<(<)>>(Any $a, Any $b --> Bool:D) {
    nqp::if(
      nqp::eqaddr(nqp::decont($a),nqp::decont($b)),
      False,                    # X (<) X is always False
      nqp::if(
        nqp::istype((my $aset := $a.Set(:view)),Set),
        nqp::if(
          nqp::istype((my $bset := $b.Set(:view)),Set),
          $aset (<) $bset,
          $bset.throw
        ),
        $aset.throw
      )
    )
}
# U+2282 SUBSET OF
only sub infix:<⊂>($a, $b --> Bool:D) is pure {
    $a (<) $b;
}
# U+2284 NOT A SUBSET OF
only sub infix:<⊄>($a, $b --> Bool:D) is pure {
    not $a (<) $b;
}

only sub infix:<<(>)>>(Any $a, Any $b --> Bool:D) {
    $b (<) $a
}
# U+2283 SUPERSET OF
only sub infix:<⊃>($a, $b --> Bool:D) is pure {
    $b (<) $a
}
# U+2285 NOT A SUPERSET OF
only sub infix:<⊅>($a, $b --> Bool:D) is pure {
    not $b (<) $a
}

# vim: ft=perl6 expandtab sw=4
