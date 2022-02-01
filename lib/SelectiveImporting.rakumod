use nqp;

sub stash_hash_helper(Mu \s, $e1, $arr) {
    my $res := $e1;
    for @$arr -> $a {
        $res := s.stash_hash($res{$a});
    }
    return $res;
}

sub trans_hash(\allitems, $trans = Any, $keep-others=True) {
    my $res := nqp::hash();
    if ($trans === Any) || (%$trans.elems == 0) {
        for allitems.keys { # to nqp::hash
            $res{$_} := allitems{$_};
        }
    } else {
        if $keep-others {
            for allitems { # to nqp::hash, and rename keys in $trans
                my $newk := %$trans{$_};
                my $k := $newk === Any ?? $_ !! $newk;
                $res{$k} := allitems{$_};
            }
        } else {
            for %$trans { # to nqp::hash, and keep & rename keys in $trans
                $res{%$trans{$_}} := allitems{$_};
            }
        }
    }
    $res;
}

sub EXPORT(|) {
    role AnotherBetterWorld {
        method do_import(Mu $/ is raw, $handle, $package_source_name, Mu $arglist? is raw) {
            # dd $arglist;
            my $EXPORT := $handle.export-package;
            if nqp::defined($arglist) {
                # my $Array := self.find_single_symbol('Array', :setting-only);
                # my $List := self.find_single_symbol('List', :setting-only);
                my $Pair := self.find_single_symbol('Pair', :setting-only);

                my %trans; # from => to
                my $toinstalled := nqp::hash();

                my $OURITEMS := stash_hash_helper(self, $handle.globalish-package, $package_source_name.split("::"));
                my $EXPORTITEMS := self.stash_hash($EXPORT{"ALL"});
                for $arglist -> $t {
                    # if (nqp::istype($tag, $Array) or nqp::istype($tag, $List)) {
                    if nqp::istype($t, $Pair) {
                        %trans{$t.key} = $t.value;
                    } else {
                        %trans{$t} = $t;
                    }
                }
                for %trans.keys -> $k {
                    my $v := %trans{$k};
                    my $tmp1 := $EXPORTITEMS{$k};
                    my $tmp2 := $OURITEMS{$k};
                    if not $tmp1 === Any {
                        $toinstalled{$v} := $tmp1;
                    } elsif not $tmp2 === Any {
                        $toinstalled{$v} := $tmp2;
                    } else {
                        nqp::die("no export or our $k in $package_source_name");
                    }
                }
                # say %trans;
                # say $toinstalled;
                self.import($/, $toinstalled, $package_source_name);
                return;
            }
            if nqp::defined($EXPORT) {
                $EXPORT := $EXPORT.FLATTENABLE_HASH();
                my @to_import := ['MANDATORY'];
                my @positional_imports := [];
                # will not reach here
                if nqp::defined($arglist) {
                    my $Pair := self.find_single_symbol('Pair', :setting-only);
                    for $arglist -> $tag {
                        if nqp::istype($tag, $Pair) {
                            my $tag1 := nqp::unbox_s($tag.key);
                            if nqp::existskey($EXPORT, $tag1) {
                                my $tmphash := trans_hash(self.stash_hash($EXPORT{$tag1}));
                                self.import($/, $tmphash, $package_source_name);
                            }
                            else {
                                self.throw($/, ['X', 'Import', 'NoSuchTag'],
                                    source-package => $package_source_name, :$tag)
                            }
                        }
                        else {
                            # nqp::push(@positional_imports, $tag);
                            @positional_imports.push($tag);
                        }
                    }
                }
                else {
                    # nqp::push(@to_import, 'DEFAULT');
                    @to_import.push('DEFAULT');
                }
                for @to_import -> $tag {
                    if nqp::existskey($EXPORT, $tag) {
                        my $tmphash := trans_hash(self.stash_hash($EXPORT{$tag}));
                        self.import($/, $tmphash, $package_source_name);
                    }
                }
                my &EXPORT = $handle.export-sub;
                if nqp::defined(&EXPORT) {
                    my $result := &EXPORT(|@positional_imports);
                    my $Map := self.find_single_symbol('Map', :setting-only);
                    if nqp::istype($result, $Map) {
                        my $tmphash := trans_hash($result.hash.FLATTENABLE_HASH());
                        self.import($/, $tmphash, $package_source_name, :need-decont(!(nqp::what($result) =:= $Map)));
#                    $/.check_LANG_oopsies("do_import");
                    }
                    else {
                        nqp::die("&EXPORT sub did not return a Map");
                    }
                }
                else {
                    if +@positional_imports {
                        self.throw($/, ['X', 'Import', 'Positional'],
                            source-package => $package_source_name)
                    }
                }
            }
        }
    }

    $*W.HOW.mixin($*W, AnotherBetterWorld);
    {}
}
