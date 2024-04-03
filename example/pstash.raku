#!/usr/bin/env raku

use KHPH;

sub MAIN (
            Str   :$user-id = 'A028441',
            Str:D :$stash-path!,
         ) {
    my KHPH $secret-string .= new(
        :herald('IBM Spectrum Protect Administrator Password Stash'),
        :prompt($user-id ~ ' password'),
        :$stash-path,
    );
    put $secret-string.expose;
}

