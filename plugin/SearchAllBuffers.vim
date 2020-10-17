scriptencoding utf-8
if exists('g:load_SearchAllBuffers')
    finish
endif
let g:load_SearchAllBuffers = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(SearchAllBuffers#Search) :<C-u>call SearchAllBuffers#Search()<CR>
nnoremap <silent> <Plug>(SearchAllBuffers#ThisWord) :<C-u>call SearchAllBuffers#ThisWord()<CR>
vnoremap <silent> <Plug>(SearchAllBuffers#SelectedWord) :<C-u>call SearchAllBuffers#SelectedWord()<CR>
nmap <Space>/ <Plug>(SearchAllBuffers#Search)
nmap <Space>* <Plug>(SearchAllBuffers#ThisWord)
vmap <Space>* <Plug>(SearchAllBuffers#SelectedWord)

let &cpo = s:save_cpo
unlet s:save_cpo