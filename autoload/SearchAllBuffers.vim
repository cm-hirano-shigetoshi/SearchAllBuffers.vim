scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfyml = "fzfyml3 run"
let s:tool_dir = expand("<sfile>:p:h")
let s:yaml = s:tool_dir . "/SearchAllBuffers.yml"

function! SearchAllBuffers#Core(word)
    function! GetWorkBufferIndex(index)
        while 1
            if buflisted(a:index)
                return a:index
            endif
            let a:index += 1
        endwhile
    endfunction

    let s:orig_buf = bufnr('%')
    let buf_n = bufnr('$')
    enew
    let work_buf_idx = GetWorkBufferIndex(bufnr('$'))
    for i in range(1, buf_n)
        if !buflisted(i)
            continue
        endif
        let buf_name = bufname(i)
        if strlen(buf_name) == 0
            let buf_name = "[No Name]"
        endif
        let buf_name = i . ":" . buf_name . ":"
        call execute(i . "buffer")
        let lines = map(getline(0, '$'),  {idx, val -> buf_name . (idx + 1) . ":" . val})
        call appendbufline(work_buf_idx, 0, lines)
    endfor
    call execute(work_buf_idx . "buffer")
    let s:temp_file = tempname()
    let s:temp_pipe = s:temp_file . 'p'
    call execute("w! !cat | tee " . s:temp_file . " > " . s:temp_pipe . " &")
    bwipeout!
    if has('nvim')
        let s:tmpfile = tempname()
        function! OnFzfExit(job_id, data, event)
            bwipeout!
            let lines = readfile(s:tmpfile)
            if len(lines) > 0
                for f in split(lines[0], "\n")
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
        call termopen(s:fzfyml . " " . s:yaml . " " . s:temp_pipe . " " . s:temp_file . " '" . a:word . "' > " . s:tmpfile, {'on_exit': 'OnFzfExit'})
        startinsert
    else
        let out = system("tput cnorm > /dev/tty; " . s:fzfyml . " " . s:yaml . " " . s:temp_pipe . " " . s:temp_file . " '" . a:word . "' 2>/dev/tty")
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