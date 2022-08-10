NAME
====

SelectiveImporting - Selective importing, and making aliases from modules

SYNOPSIS
========

Installation: `zef install SelectiveImporting`

```raku
use SelectiveImporting;

use JSON::Fast :select<&to-json &from-json>; # or just `use JSON::Fast`
use JSON::Tiny :select('&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny');

# say &to-json.package;        # (Fast)
# say &from-json.package;      # (Fast)
# say &to-json-tiny.package;   # (Tiny)
# say &from-json-tiny.package; # (Tiny)
```

DESCRIPTION
===========

Aims:
  * Import selectively
  * Avoid name conflicts

Behavior after `use SelectiveImporting`:
  * if there is no arglist in `use` statement, e.g., `use JSON::Fast`
    * `use` behaves as usual
  * else if there is no Pair "select" => !Bool
    * `use` behaves as usual
  * else if there is Pair "select" => !Bool (handled as a List, "select" => ([Str | Pair]*))
    * if `Str`
      * import it
    * if `Pair` (`'a' => 'b'`)
      * import `a` and rename it to `b`
    * Special `Pair`s
      * `"our" => ([Str | Pair]*)` for importing items marked as `our`
      * `:exportSub`: whether importing all from `sub EXPORT` or not
    * **Notes** in this case
      * all implicit tags will be ignored, like `:DEFAULT`, `:MANDATORY`, must be marked explicitly
      * items generated by `sub EXPORT` are not imported by default, use `:exportSub` in `:select` to enable it if not `:select` some
      * if tags or `:exportSub` exist, it will import all items from them, and rename items using `Str`|`Pair` except `:our(...)`; if there is not any alias, import without renaming
      * if items don't exist in given `:tag`, it will import from `:ALL`

How to import via `:select`:
  * `class` X: 'X'
  * `routine` f: '&f'
  * `variable` \$a: '$a' (@a, %a)
  * `sub postfix:<`!`>`: '&postfix:<!>'
  * `enum` X \<a b c d\>: 'X'
    * could import 'a', 'b' to use them directly instead of `X::a` via `:select<X a b>`
  * `constant` X: 'X'
  * `package` X: 'X'

Use cases:
  * use XXX :select\<a b \$c \&d\>
  * use XXX :select('a', 'b')
  * use XXX :select('a' => 'aa', 'b' => 'bb')
  * use XXX :select('a' => 'aa', 'b' => 'bb', 'c', 'd')
  * use XXX :select(|\<c d\>, 'a' => 'aa', 'b' => 'bb', 'e')
  * use XXX :select(|\<c d\>, 'a' => 'aa', 'b' => 'bb', :exportSub)
  * use XXX :select(|\<c d\>, 'a' => 'aa', 'b' => 'bb', :exportSub, :our\<oa ob\>)
  * use XXX :select(|\<c d\>, 'a' => 'aa', 'b' => 'bb', :exportSub, :our('oa' => 'oaa', 'ob' => 'obb', 'oc'))
  * use XXX :DEFAULT, :select\<a b\>
  * use XXX :tag1, :tag2, :select\<a b\>

How to use other words instead of `select`:
  * `use SelectiveImporting ({:select("get")},)`;
  * then `use XXX :get(...)`
  * please check examples/change-key.raku for more details

Examples:
  * examples/*.raku
  * t/*.rakumod *.rakutest

Similar module: https://raku.land/zef:wukgdu/CustomImporting (which imports items and makes aliases through function)

Ref:
  * https://docs.raku.org/language/modules#Exporting_and_selective_importing
  * https://github.com/rakudo/rakudo/blob/master/src/Perl6/World.nqp
  * https://github.com/FROGGS/p6-if

Note:
  * It modifies the default `do_import` in `Perl6/World.nqp`
  * It doesn't work in REPL
  * It doesn't deal with `EXPORTHOW`

AUTHOR
======

wukgdu <wukgdu365@yahoo.com>

https://github.com/wukgdu

COPYRIGHT AND LICENSE
=====================

Copyright 2022 wukgdu

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

