scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfyml = "fzfyml run"
let s:tool_dir = expand("<sfile>:p:h")
let s:yaml = s:tool_dir . "/SearchAllBuffers.yml"


function! SearchAllBuffers#Core(word)
    let temp = tempname()
    let orig_buf_idx = bufnr("%")
    for i in range(1, bufnr("$"))
        if !bufloaded(i)
            continue
        endif
        let buf_name = bufname(i)
        if strlen(buf_name) == 0
            let buf_name = "[No Name]"
        endif
        let buf_name = i . ":" . buf_name
        call execute(i . ".buffer")
        call execute("w! !cat | " . s:tool_dir . "/to_grep_style.py '" . buf_name . "' >> " . temp)
    endfor
    let out = system("tput cnorm > /dev/tty; " . s:fzfyml . " " . s:yaml . " " . temp . " '" . a:word . "' 2>/dev/tty")
    if len(out) > 0
        for f in split(out, "\n")
            let file_line = split(f, ":")
            call execute(file_line[0] . ".buffer | normal " . file_line[2] . "ggzz")
        endfor
    else
        call execute(orig_buf_idx . ".buffer")
    endif
endfunction

function! SearchAllBuffers#Search()
    call SearchAllBuffers#Core("")
endfunction

function! SearchAllBuffers#ThisWord()
    let word = expand('<cword>')
    call SearchAllBuffers#Core(word)
endfunction

function! SearchAllBuffers#SelectedWord()
    let tmp = @@
    silent normal gvy
    let word = @@
    let @@ = tmp
    call SearchAllBuffers#Core(word)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo