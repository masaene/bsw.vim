scriptencoding utf-8 

if exists('g:loaded_bsw')
finish
endif

let g:loaded_bsw = 1
silent nnoremap <C-k> :call bsw#buf_to_prev()<CR>
silent nnoremap <C-j> :call bsw#buf_to_next()<CR>
silent nnoremap <C-l> :call bsw#view_switch()<CR>
