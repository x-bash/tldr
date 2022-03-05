
# Section: utils
# From xrc awk/lib/str
function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_quote2(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}
# EndSections

BEGIN{
    print "{"

    body = ""
}

function body_add( e ){
    body = body "\n" e
}

{
    $0 = str_trim( $0 )

    if ($0 ~ /^[ \t\r]*$/){

    } else if ($1~/^#/)
    {
        gsub(/^#[ ]*/, "", $0)
        print "\"t\""
        print ":"
        print str_quote2( $0 )
    } else if ($1~/^>/) {
        gsub(/^>[ ]*/, "", $0)
        desc = desc ( (desc == "") ? "" : "\\n" ) $0
    } else if ($1 ~ /^-/) {
        gsub(/^-[ ]*/, "", $0)
        cmd_info = $0
    } else {
        if ($0 !~ /^`[^`]+`/)  next

        # gsub("`","  ",$0)
        # print "aaa " $0

        body = body ( (body == "") ? "" : "\n," )
        body = body "\n{"

        body = body "\n\"d\""
        body = body "\n:"
        body = body "\n" str_quote2( cmd_info )

        body = body "\n,"

        body = body "\n\"c\""
        body = body "\n:"
        body = body "\n" str_quote2( substr($0, 2, length($0)-2) )

        body = body "\n}"

        cmd_info = ""
    }
}

END{
    print ","
    print "\"d\""
    print ":"
    print str_quote2( desc )

    print ","
    print "\"b\""
    print ":"
    print "["
    print body
    print "]"
    print "}"
}
