NAME
====

SelectiveImporting - Selective importing, and making aliases from modules

SYNOPSIS
========

Installation: `zef install SelectiveImporting`

```raku
use SelectiveImporting;
use if; # for fun and testing

use JSON::Fast:if(True) :select<&to-json &from-json>;
# or just `use JSON::Fast :select<&to-json &from-json>;` without :if
# or just `use JSON::Fast;`
use JSON::Tiny :select('&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny');

# say &to-json.package;      # (Fast)
# say &from-json.package;    # (Fast)
# say &to-json-tiny.package; # (Tiny)
# say &to-json-tiny.package; # (Tiny)
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
    * **Note** in this case
      * all implicit tags will be ignored, like `:DEFAULT`, `:MANDATORY`, must be marked explicitly
      * if tags or `:exportSub` exist, it will import all items from them, and rename items using `Str`|`Pair` except `:our(...)`; if `'select' => ()`, import without renaming
      * if aliases don't exist in mentioned `:tag`, it will import from `:ALL`

Examples:
  * examples/*.raku
  * t/*.rakumod *.rakutest

Similar module: https://raku.land/zef:wukgdu/CustomImporting (which imports items and makes aliases through function)

Ref:
  * https://docs.raku.org/language/modules#Exporting_and_selective_importing
  * https://github.com/rakudo/rakudo/blob/master/src/Perl6/World.nqp
  * https://github.com/FROGGS/p6-if

AUTHOR
======

wukgdu <wukgdu365@yahoo.com>

https://github.com/wukgdu

COPYRIGHT AND LICENSE
=====================

Copyright 2022 wukgdu

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

