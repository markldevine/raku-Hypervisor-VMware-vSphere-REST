unit grammar Hypervisor::VMware::vSphere::REST::Grammars::DateTime:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

token TOP {
    ^
    $<year>          = [\d] ** 4 '-'
    $<numeric-month> = [\d] ** 2 '-'
    $<day-of-month>  = [\d] ** 2
    'T'
    $<hour>          = [\d] ** 2 ':'
    $<minute>        = [\d] ** 2 ':'
    $<second>        = [\d] ** 2 '.'
                        \d  ** 3
    'Z'
    $
}

class Actions {
    method TOP ($/) {
        $/.make(DateTime.new(
            year    => $/<year>,
            month   => $/<numeric-month>,
            day     => $/<day-of-month>,
            hour    => $/<hour>,
            minute  => $/<minute>,
            second  => $/<second>,
        ));
    }
}
