""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extended search tools for Vim
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.6
" Description:	Commands and maps for extended searches in Vim
" Last Change:	2014-09-30
" License:	Vim License (see :help license)
" Location:	plugin/SearchParty.vim
" Website:	https://github.com/dahu/SearchParty
"
" See SearchParty.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help SearchParty
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:SearchParty_version = '0.6'   " play nice with vim-indexed-search

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard {{{2
" uncomment after plugin development
"if exists("g:loaded_SearchParty")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
let g:loaded_SearchParty = 1


" Literal Search {{{1

nnoremap <silent> <Plug>SearchPartyFindLiteralFwd
      \ :<C-U>call searchparty#literal_search#find_literal(1)<CR>

if !hasmapto('<Plug>SearchPartyFindLiteralFwd')
  nmap <unique> <silent> <leader>/ <Plug>SearchPartyFindLiteralFwd
endif

nnoremap <silent> <Plug>SearchPartyFindLiteralBkwd
      \ :<C-U>call searchparty#literal_search#find_literal(0)<CR>

if !hasmapto('<Plug>SearchPartyFindLiteralBkwd')
  nmap <unique> <silent> <leader>? <Plug>SearchPartyFindLiteralBkwd
endif

" SearchParty Arbitrary Matches {{{1

nnoremap <Plug>SearchPartySetMatch
      \ :call searchparty#arbitrary_matches#match()<cr>

if !hasmapto('<Plug>SearchPartySetMatch')
  nmap <unique> <leader>mm <Plug>SearchPartySetMatch<CR>
endif

nnoremap <Plug>SearchPartyDeleteMatch
      \ :call searchparty#arbitrary_matches#match_delete()<CR>

if !hasmapto('<Plug>SearchPartyDeleteMatch')
  nmap <unique> <leader>md <Plug>SearchPartyDeleteMatch
endif

command! -bar -nargs=0 SearchPartyMatchList
      \ call searchparty#arbitrary_matches#match_list()

command! -bar -nargs=? SearchPartyMatchDelete
      \ call searchparty#arbitrary_matches#match_delete(<args>)

command! -bar -nargs=1 SearchPartyMatchNumber
      \ call searchparty#arbitrary_matches#match_number(<args>)

" M.A.S.H {{{1

hi MashFOW ctermfg=black ctermbg=NONE guifg=black guibg=NONE

augroup SP_MASH
  au!
  autocmd BufRead,BufNew * let b:mash_use_fow = 0
augroup END

" Shadow Maps
for lhs in ['n', 'N', '#', '*', 'g#', 'g*']
  exec 'nnoremap <silent> <Plug>SearchPartyMashShadow' . lhs . ' ' . lhs
        \ . ':call searchparty#mash#mash()<CR>'
  if !hasmapto('<Plug>SearchPartyMashShadow' . lhs)
    exec 'silent! nmap <unique> ' . lhs . ' <Plug>SearchPartyMashShadow'.lhs
  endif
endfor

function! SPAfterSearch()
  if exists('b:searching') && b:searching
    call searchparty#mash#mash()
    for x in range(10)
      if exists('*AfterSearch_' . x)
        call call('AfterSearch_' . x, [])
      endif
    endfor
  endif
  let b:searching = 0
endfunction

augroup SearchPartySearching
  au!
  au VimEnter * call SPInitialiseSearchMaps()
  au BufEnter * let b:searching = 0
  au CursorHold * call SPAfterSearch()
augroup END

function! SPInitialiseSearchMaps()
  if exists(':ShowSearchIndex')
    nnoremap / :call searchparty#mash#unmash()<bar>let b:searching=1<bar>ShowSearchIndex<cr>/
    nnoremap ? :call searchparty#mash#unmash()<bar>let b:searching=1<bar>ShowSearchIndex<cr>?
  else
    nnoremap / :call searchparty#mash#unmash()<bar>let b:searching=1<cr>/
    nnoremap ? :call searchparty#mash#unmash()<bar>let b:searching=1<cr>?
  endif
endfunction



nnoremap <silent> <Plug>SearchPartyMashFOWToggle
      \ :let b:mash_use_fow = b:mash_use_fow ? 0 : 1<CR>
      \:call searchparty#mash#mash()<CR>

if !hasmapto('<Plug>SearchPartyMashFOWToggle')
  nmap <unique> <leader>mf <Plug>SearchPartyMashFOWToggle
endif

" backwards compatible to my deprecated vim-MASH plugin
nmap <silent> <Plug>MashFOWToggle  <Plug>SearchPartyMashFOWToggle

" Multiple Replacements {{{1

nnoremap <Plug>SearchPartyMultipleReplace
      \ :call searchparty#multiple_replacements#multiply_replace()<CR>

if !hasmapto('<Plug>SearchPartyMultipleReplace')
  nmap <unique> <silent> <leader>mp <Plug>SearchPartyMultipleReplace
endif

" Search Highlighting {{{1
"--------------------
" Temporarily clear highlighting
nnoremap <Plug>SearchPartyHighlightClear
      \ :let b:mash_use_fow = 0<cr>
      \:call searchparty#mash#unmash()<bar>noh<cr>

if !hasmapto('<Plug>SearchPartyHighlightClear')
  nmap <unique> <silent> <c-l> <c-l><Plug>SearchPartyHighlightClear
endif

" Toggle search highlighting
nnoremap <Plug>SearchPartyHighlightToggle :let &hlsearch = searchparty#mash#toggle()<bar>set hlsearch?<cr>

if !hasmapto('<Plug>SearchPartyHighlightToggle')
  nmap <unique> <silent> <c-Bslash> <Plug>SearchPartyHighlightToggle
endif

" Highlight all occurrences of word under cursor
nnoremap <Plug>SearchPartyHighlightWord
      \ :let @/='\<'.expand('<cword>').'\>'<bar>set hlsearch<cr>viwo<esc>

if !hasmapto('<Plug>SearchPartyHighlightWord')
  nmap <unique> <silent> <leader>* <Plug>SearchPartyHighlightWord
endif

" Highlight all occurrences of visual selection
xnoremap <Plug>SearchPartyHighlightVisual
      \ :<c-U>let @/=searchparty#visual#element()<bar>set hlsearch<cr>

if !hasmapto('<Plug>SearchPartyHighlightVisual')
  xmap <unique> <silent> <leader>* <Plug>SearchPartyHighlightVisual
endif

" Highlight all occurrences of WORD under cursor
nnoremap <Plug>SearchPartyHighlightWORD
      \ :let @/=expand('<cWORD>')<bar>set hlsearch<cr>

if !hasmapto('<Plug>SearchPartyHighlightWORD')
  nmap <unique> <silent> <leader>g* <Plug>SearchPartyHighlightWORD
endif

" Manual Search Term from input
" -----------------------------
nnoremap <Plug>SearchPartySetSearch
      \ :let @/=input("set search: ")<bar>set hlsearch<cr>

if !hasmapto('<Plug>SearchPartySetSearch')
  nmap <unique> <silent> <leader>ms <Plug>SearchPartySetSearch
endif

" Visual Search & Replace
" -----------------------
" Use * and # in visual mode to search for visual selection
" Use & in visual mode to prime a substitute based on visual selection
" Use g& in visual mode to repeat the prior change

xnoremap <Plug>SearchPartyVisualFindNext   :<c-u>call searchparty#visual#find('/')<cr>

if !hasmapto('<Plug>SearchPartyVisualFindNext')
  xmap <unique> <silent> * <Plug>SearchPartyVisualFindNext
endif

xnoremap <Plug>SearchPartyVisualFindPrev   :<c-u>call searchparty#visual#find('?')<cr>

if !hasmapto('<Plug>SearchPartyVisualFindPrev')
  xmap <unique> <silent> # <Plug>SearchPartyVisualFindPrev
endif

xnoremap <Plug>SearchPartyVisualSubstitute :<c-u>%s/<c-r>=searchparty#visual#element()<cr>

if !hasmapto('<Plug>SearchPartyVisualSubstitute')
  xmap <unique> & <Plug>SearchPartyVisualSubstitute
endif

xnoremap <Plug>SearchPartyVisualChangeAll     :s/\<<c-r>-\>/\=@./g<cr>
xnoremap <Plug>SearchPartyVisualChangeAllBare :s/<c-r>-/\=@./g<cr>

if !hasmapto('<Plug>SearchPartyVisualChangeAll')
  xmap <unique> g& <Plug>SearchPartyVisualChangeAll
endif

if !hasmapto('<Plug>SearchPartyVisualChangeAllBare')
  xmap <unique> gg& <Plug>SearchPartyVisualChangeAllBare
endif

" Toggle Auto Highlight Cursor Word {{{1
" ---------------------------------

nnoremap <Plug>SearchPartyToggleAutoHighlightWord
      \ :call searchparty#search_highlights#toggle_AHCW()<CR>

if !hasmapto('<Plug>SearchPartyToggleAutoHighlightWord')
  nmap <unique> <silent> <leader>mah <Plug>SearchPartyToggleAutoHighlightWord
endif

" PrintWithHighlighting {{{1

command! -range=% -nargs=* P
      \ <line1>,<line2>call searchparty#search_highlights#print(<q-args>)

" Replace Within SearchHighlights {{{1

noremap <Plug>SearchPartySearchHighlightReplace
      \ :call searchparty#search_highlights#replace()<CR>

if !hasmapto('<Plug>SearchPartySearchHighlightReplace', 'n')
  nmap <unique> <silent> <leader>mar <Plug>SearchPartySearchHighlightReplace
endif

if !hasmapto('<Plug>SearchPartySearchHighlightReplace', 'v')
  xmap <unique> <silent> <leader>mar <Plug>SearchPartySearchHighlightReplace
endif

command! -range=% -nargs=0 SearchHighlightReplace
      \ <line1>,<line2>call searchparty#search_highlights#replace()

" Search Within A Range {{{1

command! -range=% -nargs=* RSearch
      \ exe '/\%(\%>'.(<line1>-1).'l\%<'.(<line2>+1).'l\)\&\%(<args>\)/'

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
"