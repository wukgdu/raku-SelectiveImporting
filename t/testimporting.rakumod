unit module testimporting;

our $v1 = 42;
our $v2 is export = 1024;

our @arr is export = [1, 2, 3];
our $arr2 is export = [1, 2, 3];

sub postfix:<!>($a) is export {
    return [*] 1..$a;
}

our sub asdf1() {
    return "our asdf1";
}

sub asdf2() is export {
    return "exported asdf2";
}

our sub testimporting::asdf3() {
    return "our testimporting::asdf3";
}

sub testimporting::asdf4() is export {
    return "exported testimporting::asdf4";
}
our sub asdf5() is export {
    return "our exported asdf5";
}

class class1 is export {

}

class testimporting::class2 {

}

our class class3 {

}

class testimporting::class4 is export {

}

class class5 {

}
