" https://github.com/retorillo/airline-onedark.vim/
" Copyright (c) Retorillo 
" Distributed under the MIT license

let s:palette = {}
let g:airline#themes#onedark#palette = s:palette

if !exists("g:airline#themes#onedark#hue")
	let g:airline#themes#onedark#hue = 0
endif
if !exists("g:airline#themes#onedark#saturation")
	let g:airline#themes#onedark#saturation = -0.05
endif
if !exists("g:airline#themes#onedark#value")
	let g:airline#themes#onedark#value = 0
endif

function! s:str2rgb(str)
	let l:r = str2nr(strpart(a:str, 1, 2), 16) / 255.0
	let l:g = str2nr(strpart(a:str, 3, 2), 16) / 255.0
	let l:b = str2nr(strpart(a:str, 5, 2), 16) / 255.0
	return [l:r, l:g, l:b]
endfunction
function! s:rgb2str(rgb)
	let l:r = float2nr(round(a:rgb[0] * 255))
	let l:g = float2nr(round(a:rgb[1] * 255))
	let l:b = float2nr(round(a:rgb[2] * 255))
	return printf("#%02x%02x%02x", l:r, l:g, l:b)
endfunction
function! s:fmin(arr)
	let l:min = a:arr[0]
	for l:i in a:arr 
		let l:min = (l:min < l:i) ? l:min : l:i
	endfor
	return l:min
endfunction
function! s:fmax(arr)
	let l:max = a:arr[0]
	for l:i in a:arr 
		let l:max = (l:max > l:i) ? l:max : l:i
	endfor
	return l:max
endfunction
function! s:linearlimit(a)
	return s:fmax([s:fmin([a:a, 1.0]), 0.0])
endfunction
function! s:circuitlimit(a)
	let l:a = fmod(a:a, 1.0)
	return l:a < 0.0 ? l:a + 1.0 : l:a
endfunction
function! s:rgb2hsv (rgb)
	let l:r = s:linearlimit(a:rgb[0])
	let l:g = s:linearlimit(a:rgb[1])
	let l:b = s:linearlimit(a:rgb[2])
	let l:M = s:fmax(a:rgb)
	let l:m = s:fmin(a:rgb)
	let l:c = l:M - l:m
	if l:c == 0.0
		let l:h = 0.0
	elseif l:M == l:r
		let l:h = (l:g - l:b) / l:c
		let l:h = fmod(l:h, 6.0)
		let l:h = l:h / 6.0
	elseif l:M == l:g
		let l:h = l:b - l:r
		let l:h = l:h / (l:c * 6.0)
		let l:h = l:h + 1.0 / 3.0
	else
		let l:h = (l:r - l:g) 
		let l:h = l:h / (l:c * 6.0)
		let l:h = l:h + 2.0 / 3.0
	endif
	let l:v = l:M
	if l:v == 0.0
		let l:s = 0.0
	else
		let l:s = l:c / l:v
	endif
	let l:h = s:circuitlimit(l:h)
	let l:s = s:linearlimit(l:s)
	let l:v = s:linearlimit(l:v)
	return [l:h, l:s, l:v]
endfunction
function! s:hsv2rgb (hsv)
	let l:h = s:circuitlimit(a:hsv[0])
	let l:s = s:linearlimit(a:hsv[1])
	let l:v = s:linearlimit(a:hsv[2])
	let l:c = l:v * l:s
	let l:h2 = 6.0 * l:h
	let l:x = l:c * (1.0 - abs(fmod(l:h2, 2.0) - 1.0))
	let l:m = l:v - l:c
	let l:rgb1 = [l:m, l:m, l:m]
	if     0.0 <= l:h2 && l:h2 < 1.0
		let l:rgb2 = [l:c, l:x, 0.0]
	elseif 1.0 <= l:h2 && l:h2 < 2.0
		let l:rgb2 = [l:x, l:c, 0.0]
	elseif 2.0 <= l:h2 && l:h2 < 3.0
		let l:rgb2 = [0.0, l:c, l:x]
	elseif 3.0 <= l:h2 && l:h2 < 4.0
		let l:rgb2 = [0.0, l:x, l:c]
	elseif 4.0 <= l:h2 && l:h2 < 5.0
		let l:rgb2 = [l:x, 0.0, l:c]
	else
		let l:rgb2 = [l:c, 0.0, l:x]
	endif
	let l:r = s:linearlimit(l:rgb1[0] + l:rgb2[0])
	let l:g = s:linearlimit(l:rgb1[1] + l:rgb2[1])
	let l:b = s:linearlimit(l:rgb1[2] + l:rgb2[2])
	return [l:r, l:g, l:b]
endfunction
function! s:inchsv(c, h, s, v)
	let l:rgb = s:str2rgb(a:c)
	let l:hsv = s:rgb2hsv(l:rgb)
	let l:hsv[0] = l:hsv[0] + a:h  
	let l:hsv[1] = l:hsv[1] + a:s
	let l:hsv[2] = l:hsv[2] + a:v
	return s:rgb2str(s:hsv2rgb(l:hsv))
endfunction

let s:fblack = "#V000000"
let s:fwhite = "#FFFFFF"
" the follwing colors from geoffharcour/one-dark.vim
let s:black  = "#1E222A" " CursorLine
let s:gray   = "#292c33" " Background Color
let s:white  = "#ABB2BF" " Normal Font Color
let s:blue   = "#61afef"
let s:purple = "#c678dd"
let s:green  = "#98c379"
let s:yellow = "#e5c07b"
let s:orange = "#d19a66"
let s:red    = "#e06c75"
let s:cyan   = "#56b6c2"

function! s:guionly(fg, bg)
	return [a:fg, a:bg, '', '']
endfunction

function! s:mix(a, b, r)
	let l:x = s:str2rgb(a:a)
	let l:y = s:str2rgb(a:b)
	let l:r = l:x[0] * (1.0 - a:r) + l:y[0] * a:r
	let l:g = l:x[1] * (1.0 - a:r) + l:y[1] * a:r
	let l:b = l:x[2] * (1.0 - a:r) + l:y[2] * a:r
	return s:rgb2str([l:r, l:g, l:b])
endfunction

function! s:mktbl(bg)
	let l:bg = s:inchsv(a:bg,
		\ g:airline#themes#onedark#hue,
		\ g:airline#themes#onedark#saturation,
		\ g:airline#themes#onedark#value)
	let l:x1 = s:guionly(s:inchsv(l:bg, 0, 1, -0.7), l:bg)
	let l:x2 = s:guionly(s:inchsv(l:bg, 0, 0, 0.2), s:mix(s:black, l:bg, 0.3))
	let l:x3 = s:guionly(s:inchsv(l:bg, 0, 0, 0.3), s:gray)
	let l:mp = airline#themes#generate_color_map(l:x1, l:x2, l:x3)

	let l:wb = s:inchsv(l:bg, 0, 0.2, -0.2)
	let l:wf = s:inchsv(l:wb, 0, -0.8, 0.8)
	let l:mp.airline_warning = s:guionly(l:wf, l:wb)
	return l:mp
endfunction

let s:palette.normal   = s:mktbl(s:green)
let s:palette.insert   = s:mktbl(s:blue)
let s:palette.replace  = s:mktbl(s:cyan)
let s:palette.visual   = s:mktbl(s:purple)
let s:palette.inactive = s:mktbl(s:white) 

let s:palette.normal_modified   = copy(s:palette.normal)
let s:palette.insert_modified   = copy(s:palette.insert)
let s:palette.replace_modified  = copy(s:palette.replace) 
let s:palette.visual_modified   = copy(s:palette.visual)
let s:palette.inactive_modified = copy(s:palette.inactive)

let s:palette.accents     = {}
let s:palette.accents.red = s:guionly(s:inchsv(s:yellow, 0, 0.2, 0.2), '')
