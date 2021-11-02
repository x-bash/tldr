
# function handle_cmd(cmd, desc){

# }

# function handle_desc(desc){

# }

# function handle_title(title){

# }

# Section: visualize

function handle_cmd(cmd, desc){
    gsub(/^-[ ]*/, "", desc)
    print "cmd-info:   " desc
    print "cmd:   " substr(cmd, 2, length(cmd)-2)
}

function handle_desc(desc){
    gsub(/\n>/, "\n", desc)
    gsub(/^>/, "", desc)
    print "desc:   " desc

}

function handle_title(title){
    gsub(/^#[ ]*/, "", title)
    print "title:   " title
}

# EndSection

BEGIN {
    DESC_HANDLED = 0
    print "----------------------"
}

{
    if ($0 ~ /^[ \t\r]*$/){

    } else if ($1~/^#/)
    {
        title = $0
        handle_title(title)
    } else if ($1~/^>/) {
        desc_len = desc_len + 1
        desc[desc_len] = $0
        if (desc_text!="") desc_text = desc_text "\n"
        desc_text = desc_text $0
    } else if ($1 ~ /^-/) {
        if (DESC_HANDLED == 0) {
            handle_desc(desc_text)
            DESC_HANDLED = 1
        }
        cmd_info = $0
    } else {
        if ($0 ~ /^\`[^\`]+\`/) {
            cmd_text = $0
            cmd[cmd_text] = cmd_info
            handle_cmd(cmd_text, cmd_info)
        }
    }
}
