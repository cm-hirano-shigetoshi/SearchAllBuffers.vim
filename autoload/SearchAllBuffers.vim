scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfyml = "fzfyml run"
let s:tool_dir = expand("<sfile>:p:h")
let s:yaml = s:tool_dir . "/SearchAllBuffers.yml"

function! SearchAllBuffers#Core(word)
    let orig_buf = bufnr('%')
    let buf_n = bufnr('$')
    enew
    let temp_buf = buf_n + 1
    while 1
        if buflisted(temp_buf)
            break
        endif
        let temp_buf += 1
    endwhile
    for i in range(buf_n, 1, -1)
        if !buflisted(i)
            continue
        endif
        let buf_name = bufname(i)
        if strlen(buf_name) == 0
            let buf_name = "[No Name]"
        endif
        let buf_name = i . ":" . buf_name . ":"
        call execute(i . "buffer")
        let lines = map(getline(1, '$'),  {idx, val -> buf_name . idx . ":" . val})
        call appendbufline(temp_buf, 0, lines)
    endfor
    call execute(temp_buf . "buffer")
    let temp_file = tempname()
    let temp_pipe = temp_file . 'p'
    call execute("w! !cat | tee " . temp_file . " > " . temp_pipe . " &")
    let out = system("tput cnorm > /dev/tty; " . s:fzfyml . " " . s:yaml . " " . temp_pipe . " " . temp_file . " '" . a:word . "' 2>/dev/tty")
    call execute("bwipeout! " . temp_buf)
    if len(out) > 0
        for f in split(out, "\n")
            let file_line = split(f, ":")
            call execute(file_line[0] . ".buffer | normal " . file_line[2] . "ggzz")
        endfor
    else
        call execute(orig_buf . "buffer")
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