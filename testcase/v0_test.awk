# Section: visualize
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function get_space(space_len,
    _space, _j){
    _space=""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function handle_title(title){
    printf("\033[0;40m%s \033[0;40m", get_space(COLUMNS-1))
    printf("\033[1;33;40m%s\033[0;40m", "")
    printf("\033[1;32;40m%s: \033[0;40m", title)
    title_len=length(title)+2
}

function handle_desc(desc){
    printf("\033[1;33;40m%s\033[0;40m", desc)
    printf ( "%s\n", sprintf("%" COLUMNS-length(desc)-title_len "s", ""))
    title_len=0
}

function handle_cmd(cmd, info){
    printf("\033[0;40m%s%s\033[0;40m", get_space(COLUMNS-1), " ")
    printf("\033[1;33;40m%s\033[0;40m", cmd)
    printf ( "%s\n", sprintf("%" COLUMNS-length(cmd) "s", ""))
    gsub(/:[ ]*$/, "", info)
    # while(match(info, /`[^`]+`/)){
    #     info = substr(info,1,RSTART-1) "\033[1;35;40m" substr(info,RSTART+1, RLENGTH-2) "\033[0m" "\033[1;36;40m" substr(info, RSTART + RLENGTH)
    #     back_quote_len=back_quote_len+2
    # }
    printf("    \033[1;36;40m%s\033[0;40m", info)
    printf ( "%s\n", sprintf("%" COLUMNS-length(info)-4+back_quote_len "s", ""))
    # debug("c:"COLUMNS";l:"length(info)";b:"back_quote_len";sl:"COLUMNS-length(info)-3+back_quote_len)
    back_quote_len=0
}


# EndSection

BEGIN {
    printf("\033[0;40m%s", "")
    title_len=0
    back_quote_len=0
}

{
    if ($0 ~ /^[ \t\r]*$/){

    }else if ($1~/^#/)
    {
        title = $0
        gsub(/^#[ ]*/, "", title)
        handle_title(title)
    } else if ($1~/^>/) {
        desc = $0
        gsub(/^>[ ]*/, "", desc)
        handle_desc(desc)
    } else if ($1 ~ /^-/) {
        desc = $0
        gsub(/^-[ ]*/, "", desc)
        cmd_info = desc
    } else {
        if ($0 ~ /^`[^`]+`/) {
            cmd_text = substr($0, 2, length($0)-2)
            cmd[cmd_text] = cmd_info
            handle_cmd(cmd_text, cmd_info)
        }
    }
}

END {
    printf("\033[0;40m%s%s\033[0m\n", get_space(COLUMNS-1)," ")
}
