# use lib 'lib';
use SelectiveImporting;

use if;
use URI;
use JSON::Fast:if(True) <&to-json &from-json>;
use JSON::Tiny '&to-json' => '&to-json-tiny', '&from-json' => '&from-json-tiny';

say &to-json.package;      # (Fast)
say &from-json.package;    # (Fast)
say &to-json-tiny.package; # (Tiny)
say &to-json-tiny.package; # (Tiny)
