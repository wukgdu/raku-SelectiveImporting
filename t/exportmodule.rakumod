# https://docs.raku.org/language/modules#EXPORT

class MyModule::Class { }

our sub asdf1() is export {
    "our exported asdf1";
}
our sub asdf2() {
    "our asdf2";
}
sub asdf3() is export {
    "exported asdf3";
}
 
sub EXPORT {
    Map.new:
      '$var'      => 'one',
      '&asdf'      => sub { 'one' },
      '@array'    => <one two three>,
      '%hash'     => %( one => 'two', three => 'four' ),
      '&doit'     => sub { say 'Greetings from exported sub' },
      'ShortName' => MyModule::Class
}