" Multi-color CSV syntax — 根据实际列数动态分配 Scarlet 调色板颜色
" 每个列不同颜色, 支持引号字段 ("...")、转义引号 ("")

syn clear

let s:delim = get(b:, 'csv_delimiter', ',')
let s:dr = escape(s:delim, '|.*~[]^$\')

let s:ncols = 0
for s:ln in range(1, min([line('$'), 50]))
  let s:cnt = len(split(getline(s:ln), s:delim))
  if s:cnt > s:ncols | let s:ncols = s:cnt | endif
endfor
if s:ncols < 1 | let s:ncols = 10 | endif

let s:palette = ['#ff5252','#69f0ae','#ffab40','#448aff','#ff4081','#40c4ff','#ff80ab','#84ffff','#b9f6ca','#ffd740','#ff8a80','#ea80fc','#8c9eff','#a7ffeb','#ffe57f']

let s:qp = '"\(""\|[^"]\)*" *'

for s:i in range(1, s:ncols - 1)
  let s:c = s:palette[s:i % len(s:palette)]
  exe 'hi Col' . s:i . ' guifg=' . s:c
  if s:i < s:ncols - 1
    exe 'syn match Col' . s:i . ' /.\{-}\(' . s:dr . '\|$\)/ nextgroup=Col' . (s:i + 1) . ',QCol' . (s:i + 1)
    exe 'syn match QCol' . s:i . ' /' . s:qp . '\(' . s:dr . '\|$\)/ nextgroup=Col' . (s:i + 1) . ',QCol' . (s:i + 1)
  else
    exe 'syn match Col' . s:i . ' /.\{-}\(' . s:dr . '\|$\)/'
    exe 'syn match QCol' . s:i . ' /' . s:qp . '\(' . s:dr . '\|$\)/'
  endif
  exe 'hi! link QCol' . s:i . ' Col' . s:i
endfor

exe 'hi Col0 guifg=' . s:palette[0]
if s:ncols > 1
  exe 'syn match Col0 /.\{-}\(' . s:dr . '\|$\)/ nextgroup=Col1,QCol1'
  exe 'syn match QCol0 /' . s:qp . '\(' . s:dr . '\|$\)/ nextgroup=Col1,QCol1'
else
  exe 'syn match Col0 /.\{-}\(' . s:dr . '\|$\)/'
  exe 'syn match QCol0 /' . s:qp . '\(' . s:dr . '\|$\)/'
endif
hi! link QCol0 Col0

let b:current_syntax = "csv"
