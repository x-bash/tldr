
# function handle_cmd(cmd, desc){

# }

# function handle_desc(desc){

# }

# function handle_title(title){

# }

# Section: visualize

function handle_title(title){
    # print "title:   " title
    printf("\033[7;33m%s: \033[0m", title)
}

function handle_desc(desc){
    printf("\033[7;32m%s\033[0m\n\n", desc)

}

function handle_cmd(cmd, desc){
    # printf("\033[1;34m- %s\033[0m\n", desc)
    # printf("      \033[1;33m%s\033[0m\n", cmd)

    printf("\033[1;33m%s\033[0m\n", cmd)
    gsub(/:[ ]*$/, "", desc)
    printf("    \033[1;36m%s\033[0m\n\n", desc)
}


# EndSection

BEGIN {
    DESC_HANDLED = 0
}

{
    if ($0 ~ /^[ \t\r]*$/){

    } else if ($1~/^#/)
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
        if ($0 ~ /^\`[^\`]+\`/) {
            cmd_text = substr($0, 2, length($0)-2)
            cmd[cmd_text] = cmd_info
            handle_cmd(cmd_text, cmd_info)
        }
    }
}
