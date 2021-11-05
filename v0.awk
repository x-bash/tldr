# Section: visualize
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function get_space(space_len,_space, _j){
    _space=""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}
function cut_info_line(_info,_space_len,_info_len,_info_arr_len,_info_line){
    _info_line = ""
    _info_arr_len = 0
    _info_len = length(_info)
    split(_info,_info_arr," ")
    if (_info_len > COLUMNS-_space_len){
        for (key in _info_arr){
            _info_arr_len=_info_arr_len+length(_info_arr[key])+1
            if (_info_arr_len > COLUMNS-_space_len){
                _info_arr_len = _info_arr_len-length(_info_arr[key])
                break
            }
        }
        _info_line = _info_line substr(_info,1,_info_arr_len-1)  " " get_space(COLUMNS-_space_len-_info_arr_len) "\n" "\033[1;40m" get_space(_space_len) "" cut_info_line(substr(_info,_info_arr_len),_space_len)
    } else {
        _info_line = _info "\033[0;40m" " " get_space(COLUMNS-_space_len-length(_info)-1)
    }
    return _info_line
}
function handle_title(title){
    printf("\033[0;40m%s\033[1;40m", get_space(COLUMNS))
    printf("\033[1;33;40m%s\033[0;40m", "")
    printf("\033[1;32;40m%s: \033[0;40m", title)
    title_len=length(title)+2
}

function handle_desc(desc){
    printf("\033[1;33;40m%s\033[0;40m", desc)
    printf ( "%s\n", sprintf("%" COLUMNS-length(desc)-title_len "s", " "))
    title_len=0
}

function handle_cmd(cmd,_max_len){
    _max_len=0
    for (key in cmd){
        if (length(key) > _max_len) _max_len = length(key)
    }
    if (_max_len > COLUMNS*0.67){
        handle_long_cmd(cmd)
    }else{
        handle_short_cmd(cmd,_max_len)
    }
}

function handle_short_cmd(cmd, _max_len, text, i){
    i=0
    for (key in cmd){
        i++
        if(i%2 == 0){
            text="\033[1;37;40m" key "\033[0;40m" get_space(_max_len-length(key)+2) "\033[1;30;40m"cut_info_line(cmd[key],_max_len+2)
        }else{
            text="\033[1;33;40m" key "\033[0;40m" get_space(_max_len-length(key)+2) "\033[1;36;40m"cut_info_line(cmd[key],_max_len+2)
        }
        printf("%s\n\033[0;40m", text)
    }
}

function handle_long_cmd(cmd, info, info_len, cmd_len,cmd_arr,cmd_arr_key){
    for (key in cmd){
        printf("\033[0;40m%s%s\033[0;40m", get_space(COLUMNS-1), " ")
        cmd_len=0
        cmd_len=length(key)
        info=cmd[key]
        gsub(/:[ ]*$/, "", info)
        info_len=length(info)
        if(cmd_len > COLUMNS){
            cmd_len=cmd_len-COLUMNS
        }
        printf("\033[1;33;40m%s%s\033[0;40m", substr(key,2), get_space(COLUMNS-cmd_len+1))
        printf("    \033[1;36;40m%s\033[0;40m", cut_info_line(info,4))
        # printf ( "%s", get_space(COLUMNS-info_len-4))
    }
}


# EndSection

BEGIN {
    printf("\033[0;40m%s", "")
    title_len=0
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
            gsub("`","   ",$0)
            cmd_text = substr($0, 1, length($0)-4)
            cmd[cmd_text] = cmd_info
            cmd_info=""
            cmd_text=""
        }
    }
}

END {
    handle_cmd(cmd)
    printf("\033[0;40m%s%s\033[0m\n", get_space(COLUMNS-1)," ")
}
