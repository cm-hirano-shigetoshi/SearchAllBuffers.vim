scriptencoding utf-8
if exists('g:load_SearchAllBuffers')
    finish
endif
let g:load_SearchAllBuffers = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(SearchAllBuffers) :<C-u>call SearchAllBuffers#SearchAllBuffers("")<CR>
nmap <C-s> <Plug>(SearchAllBuffers)

let &cpo = s:save_cpo
unlet s:save_cpo