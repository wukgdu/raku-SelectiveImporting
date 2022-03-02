use SelectiveImporting;
use CustomImporting :select<&from-import>;
use JSON::Fast :select<&from-json>;

my &from-json2 := from-import(JSON::Fast, '&from-json');
say &from-json2.WHICH;
say &from-json.WHICH;
