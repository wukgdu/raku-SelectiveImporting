NAME
====

SelectiveImporting - Selective importing, and making aliases

SYNOPSIS
========

Install: `zef install SelectiveImporting`

```raku
use SelectiveImporting;
use if; # for fun and testing

use JSON::Fast:if(True) <&to-json &from-json>;
# or just `use JSON::Fast <&to-json &from-json>;` without :if
# or just `use JSON::Fast;`
use JSON::Tiny '&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny';

# say &to-json.package;      # (Fast)
# say &from-json.package;    # (Fast)
# say &to-json-tiny.package; # (Tiny)
# say &to-json-tiny.package; # (Tiny)
```

DESCRIPTION
===========

After `use SelectiveImporting`, if there is no arglist in `use` statement, it will import as usual. And if there is an arglist in `use` statement, like `use JSON::Fast <&to-json &from-json>`, it will import mentioned items and ignore others, and the tag for selective importing is also ignored, like `:ALL`, or ` :DEFAULT`. If one element in arglist is a Str, it will import as-it-is, and if a Pair, like `'&to-json' => '&to-json-fast'`, it will import the value of Pair (`&to-json-fast`) with given key of Pair (`&to-json`)'s item inside, i.e., make an alias, `'provided name' => 'your name'`.

It will search `is export` and then `our` items for importing.

Aims:
  * Import selectively
  * Avoid name conflicts


Similar module: https://raku.land/zef:wukgdu/CustomImporting (which imports items and makes aliases through function)

Ref:
  * https://docs.raku.org/language/modules#is_export
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

