# Section: visualize
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function strlen_without_color(text){
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    return wcswidth(text)
}

function get_space(space_len,_space, _j){
    _space=""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function cut_text_get_arr(_text,i){
    i=0;
    while(match(_text,/ /)){
        _arr[i]=substr(_text,1,RSTART)
        _text=substr(_text,RSTART+1)
        i++
    }
    _arr[i]=_text
    i++
    return i
}

function cut_info_line(_info,_space_len,_color,_info_len,_info_arr_len,_info_arr_real_len,_info_line,_info_srr_key){
    _info_line = ""
    _info_arr_len = 0
    _info_arr_real_len=0
    _info_srr_key=0
    _info_len = strlen_without_color(_info)
    _info_srr_key=cut_text_get_arr(_info)
    if (_info_len > COLUMNS-_space_len){
        for (i=0;i<_info_srr_key;i++){
            _info_arr_len=_info_arr_len + strlen_without_color(_arr[i])
            _info_arr_real_len=_info_arr_real_len+length(_arr[i])
            if (_info_arr_len > COLUMNS-_space_len){
                _info_arr_len = _info_arr_len-strlen_without_color(_arr[i])
                _info_arr_real_len = _info_arr_real_len-length(_arr[i])
                break
            }
        }
        _info_line = _info_line substr(_info,1,_info_arr_real_len-1)  " " get_space(COLUMNS-_space_len-_info_arr_len) ""_color get_space(_space_len) cut_info_line(substr(_info,_info_arr_real_len),_space_len,_color)
        _info_arr_len=0
        _info_arr_real_len=0
    } else {
        _info_line = _info get_space(COLUMNS-_space_len-wcswidth(_info)-1) "|"
    }
    return _color _info_line
}

function handle_title(title){
    printf("\033[0;40m%s\033[1;40m", get_space(COLUMNS))
    printf("\033[1;33;40m%s\033[0;40m", "")
    printf("\033[1;32;40m%s: \033[0;40m", title)
    title_len=wcswidth(title)+2
}

function handle_desc(desc){
    printf("\033[1;33;40m%s\033[0;40m", desc)
    printf ( "%s\n", sprintf("%" COLUMNS-wcswidth(desc)-title_len "s", " "))
    title_len=0
}


function handle_cmd(cmd,_max_len){
    _max_len=0
    for (key in cmd){
        if (wcswidth(key) > _max_len) _max_len = wcswidth(key)
    }
    if (_max_len > COLUMNS*0.67){
        handle_long_cmd(cmd)
    }else{
        handle_short_cmd(cmd,_max_len)
    }
}

function handle_short_cmd(cmd, _max_len, info, text, i){
    i=0
    for (key in cmd){
        i++
        info=cmd[key]
        if(i%2 == 0){
            while(match(key, /{{[^{]+}}/)){
                key = substr(key,1,RSTART-1) "\033[1;32;40m" substr(key,RSTART+2, RLENGTH-4) "\033[1;33;40m" substr(key, RSTART + RLENGTH)
            }
            text="\033[1;33;40m" key "\033[0;40m" get_space(_max_len-strlen_without_color(key)+2) "\033[1;32;40m" cut_info_line(info,_max_len+2, "\033[1;32;40m")
        }else{
            while(match(key, /{{[^{]+}}/)){
                key = substr(key,1,RSTART-1) "\033[1;36;40m" substr(key,RSTART+2, RLENGTH-4) "\033[1;37;40m" substr(key, RSTART + RLENGTH)
            }
            text="\033[1;37;40m" key "\033[0;40m" get_space(_max_len-strlen_without_color(key)+2) "\033[1;36;40m" cut_info_line(info,_max_len+2, "\033[1;36;40m")
        }
        printf("%s\n\033[0;40m", text)
    }
}

function handle_long_cmd(cmd, info, info_len, cmd_len){
    for (key in cmd){
        printf("\033[0;40m%s%s\033[0;40m", get_space(COLUMNS-1), " ")
        cmd_len=0
        info=cmd[key]
        while(match(key, /{{[^{]+}}/)){
            key = substr(key,1,RSTART-1) "\033[1;37;40m" substr(key,RSTART+2, RLENGTH-4) "\033[1;33;40m" substr(key, RSTART + RLENGTH)
        }
        cmd_len=strlen_without_color(key)
        gsub(/:[ ]*$/, "", info)
        info_len=wcswidth(info)
        if(cmd_len > COLUMNS){
            cmd_len=cmd_len-COLUMNS
        }
        printf("\033[1;33;40m%s%s\033[0;40m", key, get_space(COLUMNS-cmd_len))
        printf("    \033[1;36;40m%s\033[0;40m", cut_info_line(info,4,"\033[1;36;40m"))
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
            gsub("`","  ",$0)
            cmd_text = substr($0, 1, length($0)-2)
            cmd[cmd_text] = cmd_info
            cmd_info=""
            cmd_text=""
        }
    }
}

END {
    handle_cmd(cmd)
    printf("\033[0;40m%s%s\033[0m\n", get_space(COLUMNS-1)," ")
    # zqk=" Execute a java `.class` file that contains `a` main method by using just the 天气真好 name:"
    # key=get_arr(zqk)
    # for(i=0;i<key;i++){
    #     debug(_arr[i])
    # }
    # zqk="Execute a `.jar` program with debug waiting to connect on port 5005:"
    # key=get_arr(zqk)
    # for(i=0;i<key;i++){
    #     debug(_arr[i])
    # }
}
