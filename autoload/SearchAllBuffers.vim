scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfyml = "fzfyml run"
let s:tool_dir = expand("<sfile>:p:h")
let s:yaml = s:tool_dir . "/SearchAllBuffers.yml"

function! SearchAllBuffers#Core(word)
    let s:orig_buf = bufnr('%')
    let buf_n = bufnr('$')
    enew
    let s:temp_buf = buf_n + 1
    while 1
        if buflisted(s:temp_buf)
            break
        endif
        let s:temp_buf += 1
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
        call appendbufline(s:temp_buf, 0, lines)
    endfor
    call execute(s:temp_buf . "buffer")
    let temp_file = tempname()
    let temp_pipe = temp_file . 'p'
    call execute("w! !cat | tee " . temp_file . " > " . temp_pipe . " &")
    if has('nvim')
        let s:tmpfile = tempname()
        function! OnFzfExit(job_id, data, event)
            bd!
            call execute("bwipeout! " . s:temp_buf)
            let lines = readfile(s:tmpfile)
            if len(lines) > 0
                for f in lines
                    let file_line = split(f, ":")
                    call execute(file_line[0] . ".buffer | normal " . file_line[2] . "ggzz")
                endfor
            else
                call execute(s:orig_buf . "buffer")
            endif
        endfunction
        call delete(s:tmpfile)
        enew
        setlocal statusline=fzf
        setlocal nonumber
        call termopen(s:fzfyml . " " . s:yaml . " " . temp_pipe . " " . temp_file . " '" . a:word . "' > " . s:tmpfile, {'on_exit': 'OnFzfExit'})
        startinsert
    else
        let out = system("tput cnorm > /dev/tty; " . s:fzfyml . " " . s:yaml . " " . temp_pipe . " " . temp_file . " '" . a:word . "' 2>/dev/tty")
        call execute("bwipeout! " . s:temp_buf)
        if len(out) > 0
            for f in split(out, "\n")
                let file_line = split(f, ":")
                call execute(file_line[0] . ".buffer | normal " . file_line[2] . "ggzz")
            endfor
        else
            call execute(s:orig_buf . "buffer")
        endif
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