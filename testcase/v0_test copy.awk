
# function handle_cmd(cmd, desc){

# }

# function handle_desc(desc){

# }

# function handle_title(title){

# }

# Section: visualize
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function get_space(space_len,
    _space, _j){
    _space = ""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function handle_title(title){
    printf("\033[1;33;40m%s\033[0;40m", "\n")
    printf("\033[1;32;40m%s: \033[0;40m", title)
    # printf("\033[1;32;40m%s: \033[0;40m", "\n \n"title)
}

function handle_desc(desc){
    printf("\033[1;33;40m%s\n\033[0;40m", desc)
}

function handle_cmd(cmd, desc, space){
    # printf("\033[0;40m%s\033[0;40m", get_space(COLUMNS))
    printf("\033[1;33;40m \n%s\n\033[0;40m", cmd)
    gsub(/:[ ]*$/, "", desc)
    while(match(desc, /`[^`]+`/)){
        desc = substr(desc,1,RSTART-1) "\033[1;35;40m" substr(desc,RSTART+1, RLENGTH-2) "\033[0m" "\033[1;36;40m" substr(desc, RSTART + RLENGTH)
    }
    printf("    \033[1;36;40m%s\n\033[0;40m", desc)
}

# EndSection

BEGIN {
    printf("\033[0;40m%s", "")
    DESC_HANDLED = 0
    test=""
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
        # desc_len = desc_len + 1
        # desc[desc_len] = desc
        if (desc_text!="") desc_text = desc_text "\n"
        desc_text = desc_text desc
    } else if ($1 ~ /^-/) {
        if (DESC_HANDLED == 0) {
            handle_desc(desc_text)
            DESC_HANDLED = 1
        }
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
    printf("\033[0m\n")
}
