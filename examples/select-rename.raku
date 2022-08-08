# use lib 'lib';
use SelectiveImporting;

use if;
use URI;
use JSON::Fast:if(True) :select<&to-json &from-json>;
# use JSON::Fast;
use JSON::Tiny :select('&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny');

say &to-json.package;        # (Fast)
say &from-json.package;      # (Fast)
say &to-json-tiny.package;   # (Tiny)
say &from-json-tiny.package; # (Tiny)
