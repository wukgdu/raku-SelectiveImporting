use nqp;

sub stash_hash_helper(Mu \s, $e1, $arr) {
    my $res := $e1;
    for @$arr -> $a {
        $res := s.stash_hash($res{$a});
    }
    return $res;
}

sub trans_hash(\allitems, $trans = Any, :$keep-others=False, :$package_source_name = Any, :$info="our") {
    my $res := nqp::hash();
    if ($trans === Any) || ($trans.elems == 0) {
        for allitems.keys { # to nqp::hash
            $res{$_} := allitems{$_};
        }
    } else {
        if $keep-others {
            for allitems.keys -> $k { # to nqp::hash, and rename keys in $trans
                my $newk := $trans{$k};
                my $key := $newk === Any ?? $k !! $newk;
                $res{$key} := allitems{$k};
            }
        } else {
            for $trans.keys -> $k { # to nqp::hash, and keep & rename keys in $trans
                if not allitems{$k}:exists {
                    # nqp::die("$info $_ dosen't exist in $package_source_name");
                } else {
                    $res{$trans{$k}} := allitems{$k};
                }
            }
        }
    }
    $res;
}

sub EXPORT($keySelect = "select", $export-sub-key = "exportSub", $our-key = "our") {
    role AnotherBetterWorld {
        method do_import(Mu $/ is raw, $handle, $package_source_name, Mu $arglist? is raw) {
            # dd $arglist;
            my $EXPORT := $handle.export-package;

            my %trans; # from => to for aliases
            my %trans-for-our; # from => to for aliases
            # my %trans-for-EXPORT; # from => to for aliases
            my $existSelect = False;
            my $export-sub-all = False;

            my $Pair := self.find_single_symbol('Pair', :setting-only);
            my $Bool := self.find_single_symbol('Bool', :setting-only);

            if nqp::defined($arglist) {
                # my $Array := self.find_single_symbol('Array', :setting-only);
                # my $List := self.find_single_symbol('List', :setting-only);

                for $arglist -> $tag {
                    if nqp::istype($tag, $Pair) {
                        if ($tag.key eq $keySelect) and (not nqp::istype($tag.value, $Bool)) {
                            $existSelect = True;
                            for @($tag.value) -> $t {
                                if nqp::istype($t, $Pair) {
                                    if $t.key eq $export-sub-key {
                                        $export-sub-all = True;
                                    } elsif $t.key eq $our-key {
                                        for @($t.value) -> $t1 {
                                            if nqp::istype($t1, $Pair) {
                                                %trans-for-our{$t1.key} = $t1.value;
                                            } else {
                                                %trans-for-our{$t1} = $t1;
                                            }
                                        }
                                    } else {
                                        %trans{$t.key} = $t.value;
                                    }
                                } else {
                                    %trans{$t} = $t;
                                }
                            }
                        }
                    }
                }

                if %trans-for-our.elems != 0 {
                    my $OURITEMS := stash_hash_helper(self, $handle.globalish-package, $package_source_name.split("::"));
                    # say "our: ", $OURITEMS.keys;
                    my $toinstalled := trans_hash($OURITEMS, %trans-for-our, :$package_source_name, :info("our"));
                    self.import($/, $toinstalled, $package_source_name);
                }

                if %trans.elems != 0 {
                    my $EXPORTITEMS := self.stash_hash($EXPORT{"ALL"});
                    # say "export: ", $EXPORTITEMS.keys;
                    my $toinstalled := trans_hash($EXPORTITEMS, %trans, :$package_source_name, :info("export"));
                    self.import($/, $toinstalled, $package_source_name);
                }
            }
            if nqp::defined($EXPORT) {
                $EXPORT := $EXPORT.FLATTENABLE_HASH();
                my @to_import := $existSelect ?? [] !! ['MANDATORY'];
                my @positional_imports := [];
                if nqp::defined($arglist) {
                    for $arglist -> $tag {
                        if nqp::istype($tag, $Pair) {
                            if ($tag.key eq $keySelect) and (not nqp::istype($tag.value, $Bool)) {
                                next;
                            }
                            my $tag1 := nqp::unbox_s($tag.key);
                            if nqp::existskey($EXPORT, $tag1) {
                                my $tmphash := trans_hash(self.stash_hash($EXPORT{$tag1}), %trans, :keep-others);
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
                        my $tmphash := trans_hash(self.stash_hash($EXPORT{$tag}), %trans, :keep-others);
                        self.import($/, $tmphash, $package_source_name);
                    }
                }
                my &EXPORT = $handle.export-sub;
                if nqp::defined(&EXPORT) {
                    my $result := &EXPORT(|@positional_imports);
                    my $Map := self.find_single_symbol('Map', :setting-only);
                    if nqp::istype($result, $Map) {
                        my $tmphash := trans_hash($result.hash.FLATTENABLE_HASH(), %trans, :keep-others($export-sub-all));
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
