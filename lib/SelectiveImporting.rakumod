use nqp;

sub stash_hash_helper(Mu \s, $e1, $arr) {
    my $res := $e1;
    for @$arr -> $a {
        $res := s.stash_hash($res{$a});
    }
    return $res;
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

                my %trans;
                my $toinstalled := nqp::hash();

                my $OURITEMS := stash_hash_helper(self, $handle.globalish-package, $package_source_name.split("::"));
                my $EXPORTITEMS := self.stash_hash($EXPORT{"ALL"});
                for $arglist -> $t {
                    # if (nqp::istype($tag, $Array) or nqp::istype($tag, $List)) {
                    if nqp::istype($t, $Pair) {
                        %trans{$t.value} = $t.key;
                    } else {
                        %trans{$t} = $t;
                    }
                }
                for %trans.keys -> $k {
                    my $v = %trans{$k};
                    my $tmp1 := $EXPORTITEMS{$v};
                    my $tmp2 := $OURITEMS{$v};
                    if not $tmp1 === Any {
                        $toinstalled{$k} := $tmp1;
                    } elsif not $tmp2 === Any {
                        $toinstalled{$k} := $tmp2;
                    } else {
                        nqp::die("no export or our $v");
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
                                my $tmphash := nqp::hash();
                                my $exportedtaghash := self.stash_hash($EXPORT{$tag1});
                                for $exportedtaghash.keys -> $k {
                                    $tmphash{$k} := $exportedtaghash{$k};
                                }
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
                        my $tmphash := nqp::hash();
                        my $exportedtaghash := self.stash_hash($EXPORT{$tag});
                        for $exportedtaghash.keys -> $k {
                            $tmphash{$k} := $exportedtaghash{$k};
                        }
                        self.import($/, $tmphash, $package_source_name);
                    }
                }
                my &EXPORT = $handle.export-sub;
                if nqp::defined(&EXPORT) {
                    my $result := &EXPORT(|@positional_imports);
                    my $Map := self.find_single_symbol('Map', :setting-only);
                    if nqp::istype($result, $Map) {
                        my $tmphash := nqp::hash();
                        my $storage := $result.hash.FLATTENABLE_HASH();
                        for $storage.keys -> $k {
                            $tmphash{$k} := $storage{$k};
                        }
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
