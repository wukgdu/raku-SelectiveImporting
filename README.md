NAME
====

SelectiveImporting - Selective importing, and making aliases

SYNOPSIS
========

```raku
use SelectiveImporting;
use if;
use JSON::Fast:if(True) <&to-json &from-json>;
# or just `use JSON::Fast <&to-json &from-json>;`
# or just `use JSON::Fast;`
use JSON::Tiny '&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny';
use URI;

# say &to-json.package;      # (Fast)
# say &from-json.package;    # (Fast)
# say &to-json-tiny.package; # (Tiny)
# say &to-json-tiny.package; # (Tiny)
```

DESCRIPTION
===========

After `use SelectiveImporting`, if there is an arglist in `use` statement, like `use JSON::Fast <&to-json &from-json>`, it will import mentioned items and ignore others, and the tag for selective importing is also ignored, like `:ALL`, or ` :DEFAULT`. If one element in arglist is a Str, it will import as-it-is, and if a Pair, like `'&to-json' => '&to-json-fast'`, it will import the value (`&to-json-fast`) with given key (`&to-json`), i.e., makes an alias, `'provided name' => 'your name'`.

Aim:
  * Import selectively
  * Avoid name conflicts

Similar repo: https://raku.land/zef:wukgdu/CustomImporting, which imports items and makes aliases through function.

Ref: https://docs.raku.org/language/modules#is_export, https://github.com/FROGGS/p6-if

AUTHOR
======

wukgdu <wukgdu365@yahoo.com>

https://github.com/wukgdu

COPYRIGHT AND LICENSE
=====================

Copyright 2022 wukgdu

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

