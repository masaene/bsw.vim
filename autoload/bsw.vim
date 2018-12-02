scriptencoding utf-8 

if !exists('g:loaded_bsw')
finish
endif
let g:loaded_bsw = 1
let s:view_buf_no = 0xffff
let s:view_name = "bsw_view"
let s:bufinfo_list = []
let s:buf_first = 0xffff
let s:buf_last = 0xffff
let s:buf_prev = 0xffff
let s:buf_next = 0xffff

function bsw#refresh_bufinfo_list(buf_current)
	let l:idx = 0
	let l:current_idx = 0
	let s:bufinfo_list = []
	for v in getbufinfo()
		if s:view_name != bufname(v.bufnr)
			call add(s:bufinfo_list,v)
			if v.bufnr == a:buf_current
				let l:current_idx = l:idx
			endif
			let l:idx = l:idx + 1
		endif
	endfor

	let l:min_idx = 0
	let l:max_idx = len(s:bufinfo_list)-1
	let s:buf_first = s:bufinfo_list[0].bufnr
	let s:buf_last = s:bufinfo_list[l:max_idx].bufnr

	if (l:current_idx-1) < l:min_idx
		let s:buf_prev = s:buf_last
	else
		let s:buf_prev = s:bufinfo_list[l:current_idx-1].bufnr
	endif

	if (l:current_idx+1) > l:max_idx
		let s:buf_next = s:buf_first
	else
		let s:buf_next = s:bufinfo_list[l:current_idx+1].bufnr
	endif
endfunction

function bsw#view_switch()
	if 0 != bufexists(s:view_name)
		call bsw#view_close(win_getid())
	else
		call bsw#refresh_bufinfo_list(bufnr('%'))
		call bsw#view_open(win_getid())
		call bsw#refresh_view(win_getid(), bufnr('%'))
	endif
endfunction

function bsw#view_close(prev_win_no)
	if 0 != bufexists(s:view_name)
	"call win_gotoid(win_findbuf(bufnr(s:view_name))[0])
	execute 'bwipeout!' bufnr(s:view_name)
	endif
	call win_gotoid(a:prev_win_no)
endfunction

function bsw#view_open(prev_win_no)
	if 0 == bufexists(s:view_name)
		setlocal splitbelow
		execute '5new' s:view_name
	endif
		call win_gotoid(a:prev_win_no)
	endfunction

function bsw#check_goodbye()
	echo 'goodbye'
		if 1 == len(getbufinfo())
			if bufnr('$') == bufnr(s:view_name)
				:q!
			 endif
		 endif
 endfunction

function bsw#refresh_view(prev_win_no,current_buf_no)
	if 0 != bufexists(s:view_name)
		call win_gotoid(win_findbuf(bufnr(s:view_name))[0])
		:%d

		let l:i = 0
		let l:current_line = 0
		for v in s:bufinfo_list
			let l:fullbufname = split(bufname(v.bufnr),'/')
			let l:bufname = l:fullbufname[len(l:fullbufname)-1]
			if v.bufnr == a:current_buf_no
				let l:bufname = printf("%s*",l:bufname)
				let l:current_line = l:i + 1
			endif
			call append(l:i, l:bufname)
			let l:i = l:i + 1
		endfor
		call cursor(l:current_line,1)
		setlocal cursorline
		call win_gotoid(a:prev_win_no)
	endif
endfunction

function bsw#buf_to_prev()
	call bsw#refresh_bufinfo_list(bufnr('%'))
	execute 'buffer' s:buf_prev
	call bsw#view_open(win_getid())
	call bsw#refresh_view(win_getid(), bufnr('%'))
endfunction

function bsw#buf_to_next()
	call bsw#refresh_bufinfo_list(bufnr('%'))
	execute 'buffer' s:buf_next
	call bsw#view_open(win_getid())
	call bsw#refresh_view(win_getid(), bufnr('%'))
endfunction

