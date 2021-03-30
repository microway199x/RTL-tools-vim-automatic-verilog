"-----------------------------------------------------------------------------
" Vim Plugin for Verilog Code Automactic Generation 
" Author:         HonkW
" Website:        https://honk.wang
" Last Modified:  2021/03/30 22:32
"------------------------------------------------------------------------------
" Modification History:
" Date          By              Version                 Change Description")
"------------------------------------------------------------------------------
" 2021/3/26     HonkW           1.0.0                   First copy from zhangguo's vimscript
"
" For vim version 7.x or above
"-----------------------------------------------------------------------------
"Update 记录脚本更新{{{1
autocmd BufWrite automatic.vim call UpdateVimscriptLastModifyTime()
function UpdateVimscriptLastModifyTime()
    let line = getline(5)
    if line =~ '\" Last Modified'
        call setline(5,"\" Last Modified:  " . strftime("%Y/%m/%d %H:%M"))
    endif
endfunction
"}}}1

"Version 启动判断{{{1
if version < 700        "如果vim版本低于7.0则无效,类似写法为 if v:version < 703,代表版本低于7.3
   finish
endif
if exists("vlog_plugin")
   finish
endif
let vlog_plugin = 1
"}}}1

"Config 配置参数{{{1

"Position 确定信号对齐位置{{{2
let s:max_pos_name = 32
let s:max_pos_symbol = 64

"}}}2

"Timing Wave 定义波形{{{2
let s:sig_offset = 13           "Signal offset 
"let s:sig_offset = 13+4         "Signal offset (0 is clk posedge, 4 is clk negedge)
let s:clk_period = 8            "Clock period
let s:clk_num = 16              "Number of clocks generated
let s:cq_trans = 1              "Signal transition started N spaces after clock transition
let s:wave_max_wd = s:sig_offset + s:clk_num*s:clk_period       "Maximum Width
"}}}2

" Verilog Type 定义Verilog变量类型{{{2

"Port 端口类型
let s:VlogTypePort =                  '\<input\>\|'
let s:VlogTypePort = s:VlogTypePort . '\<output\>\|'
let s:VlogTypePort = s:VlogTypePort . '\<inout\>'

"Data 数据类型
let s:VlogTypeData =                  '\<wire\>\|'
let s:VlogTypeData = s:VlogTypeData . '\<reg\>\|'
let s:VlogTypeData = s:VlogTypeData . '\<parameter\>\|'
let s:VlogTypeData = s:VlogTypeData . '\<localparam\>\|'
let s:VlogTypeData = s:VlogTypeData . '\<genvar\>\|'
let s:VlogTypeData = s:VlogTypeData . '\<integer\>'

"Calculation 计算类型
let s:VlogTypeCalc =                  '\<assign\>\|'
let s:VlogTypeCalc = s:VlogTypeCalc . '\<always\>'

"Structure 结构类型
let s:VlogTypeStru =                  '\<module\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endmodule\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<function\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endfunction\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<task\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endtask\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<generate\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endgenerate\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<begin\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<end\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<case\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<casex\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<casez\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endcase\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<default\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<for\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<if\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<define\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<ifdef\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<ifndef\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<elsif\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<else\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endif\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<celldefine\>\|'
let s:VlogTypeStru = s:VlogTypeStru . '\<endcelldefine\>'

"Others 其他类型
let s:VlogTypeOthe =                  '\<posedge\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<negedge\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<timescale\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<initial\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<forever\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<specify\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<endspecify\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<include\>\|'
let s:VlogTypeOthe = s:VlogTypeOthe . '\<or\>'

"() 括号包含
let s:VlogTypePre  = '\('
let s:VlogTypePost = '\)'
let s:VlogTypeConn = '\|'

let s:VlogTypePorts = s:VlogTypePre . s:VlogTypePort . s:VlogTypePost
let s:VlogTypeDatas = s:VlogTypePre . s:VlogTypeData . s:VlogTypePost
let s:VlogTypeCalcs = s:VlogTypePre . s:VlogTypeCalc . s:VlogTypePost
let s:VlogTypeStrus = s:VlogTypePre . s:VlogTypeStru . s:VlogTypePost
let s:VlogTypeOthes = s:VlogTypePre . s:VlogTypeOthe . s:VlogTypePost

"Keywords 关键词类型
let s:VlogKeyWords  = s:VlogTypePre . s:VlogTypePort . s:VlogTypeConn .  s:VlogTypeData . s:VlogTypeConn. s:VlogTypeCalc . s:VlogTypeConn. s:VlogTypeStru . s:VlogTypeConn. s:VlogTypeOthe . s:VlogTypePost

"Not Keywords 非关键词类型
let s:not_keywords_pattern = s:VlogKeyWords . '\@!\(\<\w\+\>\)'

"}}}2

"}}}1

"Keys 快捷键{{{1

"Menu 菜单栏{{{2

"TimingWave 时序波形{{{3
amenu &Verilog.Wave.AddClk                                              :call AddClk()<CR>
amenu &Verilog.Wave.AddSig                                              :call AddSig()<CR>
amenu &Verilog.Wave.AddBus                                              :call AddBus()<CR>
amenu &Verilog.Wave.AddBlk                                              :call AddBlk()<CR>
amenu &Verilog.Wave.AddNeg                                              :call AddNeg()<CR>
amenu &Verilog.Wave.-Operation-                                         :
amenu &Verilog.Wave.Invert<TAB><C-F8>                                   :call Invert()<CR>
"}}}3

"Code Snippet 代码段{{{3
amenu &Verilog.Code.Always@.always\ @(posedge\ or\ posedge)<TAB><;al>   :call AlBpp()<CR>
amenu &Verilog.Code.Always@.always\ @(posedge\ or\ negedge)             :call AlBpn()<CR>
amenu &Verilog.Code.Always@.always\ @(*)                                :call AlB()<CR>
amenu &Verilog.Code.Always@.always\ @(negedge\ or\ negedge)             :call AlBnn()<CR>
amenu &Verilog.Code.Always@.always\ @(posedge)                          :call AlBp()<CR>
amenu &Verilog.Code.Always@.always\ @(negedge)                          :call AlBn()<CR>
amenu &Verilog.Code.Header.AddHeader<TAB><;header>                      :call AddHeader()<CR>
amenu &Verilog.Code.Comment.SingleLineComment<TAB><;//>                 :call AutoComment()<CR>
amenu &Verilog.Code.Comment.MultiLineComment<TAB>Visual-Mode\ <;/*>     :call AutoComment2()<CR>
amenu &Verilog.Code.Comment.CurLineAddComment<TAB><;/$>                 :call AddCurLineComment()<CR>
amenu &Verilog.Code.Template.LoadTemplate<TAB>                          :call LoadTemplate()<CR>
"}}}3

"}}}2

"Keyboard 键盘快捷键{{{2

"Insert Time 插入时间{{{3
imap <F2> <C-R>=strftime("%x")<CR>
"}}}3

"Invert Wave 时序波形翻转{{{3
map <C-F8>      :call Invert()<ESC>
"}}}3

"Code Snippet 代码段{{{3
"Add Always 添加always块
map ;al         :call AlBpp()<CR>i
"Add Header 添加文件头
map ;header     :call AddHeader()<CR> 
"Add Comment 添加注释
map ;//         :call AutoComment()<ESC>
map ;/*         <ESC>:call AutoComment2()<ESC>
map ;/$         :call AddCurLineComment()<ESC>
"}}}3

"}}}2

"}}}1

"Function 功能函数{{{1

"TimingWave 时序波形{{{2

function AddClk() "{{{3
    let ret = []
    let ret0 = "//  .   .   ."
    let ret1 = "//          +"
    let ret2 = "// clk      |"
    let ret3 = "//          +"
    let format = '%' . s:clk_period/2 . 'd'
    for idx in range(1,s:clk_num)
        let ret0 = ret0 . printf(format,idx) . repeat(' ',s:clk_period/2)
        let ret1 = ret1 . repeat('-',s:clk_period/2-1)
        let ret2 = ret2 . repeat(' ',s:clk_period/2-1)
        let ret3 = ret3 . repeat(' ',s:clk_period/2-1)
        let ret1 = ret1 . '+'
        let ret2 = ret2 . '|'
        let ret3 = ret3 . '+'
        let ret1 = ret1 . repeat(' ',s:clk_period/2-1)
        let ret2 = ret2 . repeat(' ',s:clk_period/2-1)
        let ret3 = ret3 . repeat('-',s:clk_period/2-1)
        let ret1 = ret1 . '+'
        let ret2 = ret2 . '|'
        let ret3 = ret3 . '+'
    endfor
    call add(ret,ret0)
    call add(ret,ret1)
    call add(ret,ret2)
    call add(ret,ret3)
    let lnum = line(".")
    let col = col(".")
    call append(line("."),ret)
    call cursor(lnum+4,col)
endfunction 
"}}}3

function AddSig() "{{{3
    let ret = []
    let ret0 = "//          "
    let ret1 = "// sig      "
    let ret2 = "//          "
    let ret0 = ret0 . repeat(' ',s:clk_num*s:clk_period+1)
    let ret1 = ret1 . repeat(' ',s:clk_num*s:clk_period+1)
    let ret2 = ret2 . repeat('-',s:clk_num*s:clk_period+1)
    call add(ret,ret0)
    call add(ret,ret1)
    call add(ret,ret2)
    let lnum = line(".")
    let col = col(".")
    call append(line("."),ret)
    call cursor(lnum+3,col)
endfunction "}}}3

function AddBus() "{{{3
    let ret = []
    let ret0 = "//          "
    let ret1 = "// bus      "
    let ret2 = "//          "
    let ret0 = ret0 . repeat('-',s:clk_num*s:clk_period+1)
    let ret1 = ret1 . repeat(' ',s:clk_num*s:clk_period+1)
    let ret2 = ret2 . repeat('-',s:clk_num*s:clk_period+1)
    call add(ret,ret0)
    call add(ret,ret1)
    call add(ret,ret2)
    let lnum = line(".")
    let col = col(".")
    call append(line("."),ret)
    call cursor(lnum+3,col)
endfunction "}}}3

function AddNeg() "{{{3
    let lnum = s:GetSigNameLineNum()
    if lnum == -1
        return
    endif
    let line = getline(lnum)
    if line =~ 'neg\s*$'
        return
    endif
    call setline(lnum,line." neg")
endfunction "}}}3

function AddBlk() "{{{3
    let ret = []
    let ret0 = "//          "
    let ret0 = ret0 . repeat(' ',s:clk_num*s:clk_period+1)
    call add(ret,ret0)
    let lnum = line(".")
    let col = col(".")
    call append(line("."),ret)
    call cursor(lnum+1,col)
endfunction "}}}3

function Invert() "{{{3
"   e.g
"   clk_period = 8
"   clk_num = 16
"   cq_trans = 1
"
"1  .   .   .   1       2       3       4       5       6       7       8       9      10      11      12      13      14      15      16    
"2          +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +
"3 clk      |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
"4          +   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+
"5
"6                           +-------+                                                                                                       
"7 sig                       |*      |                                                                                                       
"8          -----------------+       +-------------------------------------------------------------------------------------------------------
"1.........13..............29......37
"
    let lnum = s:GetSigNameLineNum()    "7
    if lnum == -1
        return
    endif

    let top = getline(lnum-1)   "line 6
    let mid = getline(lnum)     "line 7
    let bot = getline(lnum+1)   "line 8

    let signeg = s:SigIsNeg()                   "detect negative marker 
    let posedge = s:GetPosedge(signeg)          "detect nearest posedge     29
    let negedge = posedge + s:clk_period/2      "detect next negedge        33
    let next_posedge = posedge + s:clk_period   "detect next posedge        37 

    let last = s:SigLastClkIsHigh(lnum,posedge,negedge)     "detect line 6, col 29 is not '-'   last = 0
    let cur = s:SigCurClkIsHigh(lnum,posedge,negedge)       "detect line 6, col 33 is '-'       cur = 1
    let next = s:SigNextClkIsHigh(lnum,posedge,negedge)     "detect line 6, col 37 is '-'       next = 1
    let chg = s:BusCurClkHaveChg(lnum,posedge,negedge)      "judge if bus marker 'X' to see if already changed

    "from 0 to posedge+cq_trans-1{{{4
    let res_top = strpart(top,0,posedge+s:cq_trans-1)
    let res_mid = strpart(mid,0,posedge+s:cq_trans-1)
    let res_bot = strpart(bot,0,posedge+s:cq_trans-1)
    "}}}4

    "from posedge+cq_trans to (posedge+clk_period)(i.e.next_posedge)+cq_trans-1{{{4
    let init_top_char = ' '
    let init_mid_char = ' '
    let init_bot_char = ' '
    let top_char = ' '
    let mid_char = ' '
    let bot_char = ' '
    let is_bus = 0

    if top[negedge] =~ '-' && bot[negedge] =~ '-'           "two lines, must be bus
        let is_bus = 1
        if chg
            let init_top_char = '-'
            let init_mid_char = ' '
            let init_bot_char = '-'
        else
            let init_top_char = ' '
            let init_mid_char = 'X'
            let init_bot_char = ' '
        endif
        let top_char = '-'
        let mid_char = ' '
        let bot_char = '-'
        let res_top = res_top . init_top_char
        let res_mid = res_mid . init_mid_char
        let res_bot = res_bot . init_bot_char
        for idx in range(1,s:clk_period-1)
            let res_top = res_top . top_char
            let res_mid = res_mid . mid_char
            let res_bot = res_bot . bot_char
        endfor
    else                                                    "one line or none, signal
        if last == cur
            if cur                                          "last=1 cur=1 both high
                let init_top_char = '+'
                let init_mid_char = '|'
                let init_bot_char = '+'
                let top_char = ' '
                let bot_char = '-'
            else
                let init_top_char = '+'                     "last=0 cur=0 both low 
                let init_mid_char = '|'
                let init_bot_char = '+'
                let top_char = '-'
                let bot_char = ' '
            endif
        else
            if cur                                          "last=0 cur=1 posedge
                let init_top_char = ' '
                let init_mid_char = ' '
                let init_bot_char = '-'
                let top_char = ' '
                let bot_char = '-'
            else
                let init_top_char = '-'                     "last=1 cur=0 negedge
                let init_mid_char = ' '
                let init_bot_char = ' '
                let top_char = '-'
                let bot_char = ' '
            endif
        endif

        let res_top = res_top . init_top_char
        let res_mid = res_mid . init_mid_char
        let res_bot = res_bot . init_bot_char
        for idx in range(1,s:clk_period-1)
            let res_top = res_top . top_char
            let res_mid = res_mid . mid_char
            let res_bot = res_bot . bot_char
        endfor

        if next == cur                                      "cur=next=1 or 0
            let init_top_char = '+'
            let init_mid_char = '|'
            let init_bot_char = '+'
        else
            if cur
                let init_top_char = ' '
                let init_mid_char = ' '
                let init_bot_char = '-'
            else
                let init_top_char = '-'
                let init_mid_char = ' '
                let init_bot_char = ' '
            endif
        endif
        let res_top = res_top . init_top_char
        let res_mid = res_mid . init_mid_char
        let res_bot = res_bot . init_bot_char
    endif
    "}}}4

    "from posedge+clk_period+cq_trans to max{{{4
    let res_top = res_top .strpart(top,posedge+s:cq_trans+s:clk_period-is_bus,s:wave_max_wd-1)
    let res_mid = res_mid .strpart(mid,posedge+s:cq_trans+s:clk_period-is_bus,s:wave_max_wd-1)
    let res_bot = res_bot .strpart(bot,posedge+s:cq_trans+s:clk_period-is_bus,s:wave_max_wd-1)
    "}}}4

    call setline(lnum-1,res_top)
    call setline(lnum,res_mid)
    call setline(lnum+1,res_bot)

endfunction 
"}}}3

"Sub-Funciton-For-Invert(){{{3

function s:GetSigNameLineNum() "{{{4
    let lnum = -1
    let cur_lnum = line(".")
    if getline(cur_lnum) =~ '^\/\/\s*\(sig\|bus\)'
        let lnum = cur_lnum
    elseif getline(cur_lnum-1) =~ '^\/\/\s*\(sig\|bus\)'
        let lnum = cur_lnum-1
    elseif getline(cur_lnum+1) =~ '^\/\/\s*\(sig\|bus\)'
        let lnum = cur_lnum+1
    endif
    return lnum
endfunction "}}}4

function s:GetPosedge(signeg) "{{{4
    "calculate the width between col(".") and the nearest posedge
    if a:signeg == 0
        let ret = col(".") - s:sig_offset
        while 1
            if ret >= s:clk_period
                let ret = ret - s:clk_period
            else
                break
            endif
        endwhile
        return col(".") - ret
    else
        let ret = col(".") - s:sig_offset + s:clk_period/2
        while 1
            if ret >= s:clk_period
                let ret = ret - s:clk_period
            else
                break
            endif
        endwhile
        return col(".") - ret
    endif
endfunction "}}}4

function s:SigLastClkIsHigh(lnum,posedge,negedge) "{{{4
    let ret = 0
    let line = getline(a:lnum - 1)
    if line[a:posedge-1] =~ '-'
        let ret = 1
    endif
    return ret
endfunction "}}}4

function s:SigCurClkIsHigh(lnum,posedge,negedge) "{{{4
    let ret = 0
    let line = getline(a:lnum - 1)
    if line[a:negedge-1] =~ '-'
        let ret = 1
    endif
    return ret
endfunction "}}}4

function s:SigNextClkIsHigh(lnum,posedge,negedge) "{{{4
    let ret = 0
    let line = getline(a:lnum - 1)
    if line[a:negedge+s:clk_period-1] =~ '-'
        let ret = 1
    endif
    return ret
endfunction "}}}4

function s:BusCurClkHaveChg(lnum,posedge,negedge) "{{{4
    let ret = 0
    let line = getline(a:lnum)
    if line[a:posedge+s:cq_trans-1] =~ 'X'
        let ret = 1
    endif
    return ret
endfunction "}}}4

function s:SigIsNeg() "{{{4
    let ret = 0
    let lnum = s:GetSigNameLineNum()
    if getline(lnum) =~ 'neg\s*$'
        let ret = 1
    endif
    return ret
endfunction "}}}4

"}}}3

"}}}2

"AutoTemplate 快速新建.v文件{{{2

autocmd BufNewFile *.v call AutoTemplate()

function AutoTemplate() "{{{3
    let filename = expand("%")
    let modulename = matchstr(filename,'\w\+')
    call AddHeader()
    call append(22, "`timescale 1ns/1ps")
    call append(23, "")
    call append(24, "module " . modulename  )
    call append(25, "(")
    call append(26, "clk")
    call append(27, "rst")
    call append(28, ");")
    call append(29, "")
    call append(30, "endmodule")
endfunction "}}}3

"}}}2

"Update Last Modify Time 更新写入时间{{{2

autocmd BufWrite *.v call UpdateLastModifyTime()

function UpdateLastModifyTime() "{{{3
    let line = getline(8)
    if line =~ '// Last Modified'
        call setline(8,"// Last Modified : " . strftime("%Y/%m/%d %H:%M"))
    endif
endfunction "}}}3

"}}}2

"Code Snippet 代码段{{{2

function AddHeader() "{{{3
    let line = getline(1)
    if line =~ '// +FHDR'               "已有文件头的文件不再添加
        return
    endif
    
    let author = g:vimrc_author
    let company = g:vimrc_company
    let project = g:vimrc_prject
    let device = g:vimrc_device
    let email = g:vimrc_email
    let website = g:vimrc_website

    let filename = expand("%")          "记录当前文件名
    let timelen = strlen(strftime("%x"))
    let authorlen = strlen(author)

    call append(0 , "// +FHDR----------------------------------------------------------------------------")
    call append(1 , "// Project Name  : ".project)
    call append(2 , "// Device        : ".device)
    call append(3 , "// Author        : ".author)
    call append(4 , "// Email         : ".email)
    call append(5 , "// Website       : ".website)
    call append(6 , "// Create On     : ".strftime("%Y/%m/%d %H:%M"))
    call append(7 , "// Last Modified : ".strftime("%Y/%m/%d %H:%M"))
    call append(8 , "// File Name     : ".filename)
    call append(9 , "// Description   :")
    call append(10, "//         ")
    call append(11, "// ")
    call append(12, "// Copyright (c) ".strftime("%Y ") . company . ".")
    call append(13, "// ALL RIGHTS RESERVED")
    call append(14, "// ")
    call append(15, "// ---------------------------------------------------------------------------------")
    call append(16, "// Modification History:")
    call append(17, "// Date         By              Version                 Change Description")
    call append(18, "// ---------------------------------------------------------------------------------")
    call append(19, "// ".strftime("%x").repeat(" ", 13-timelen).author.repeat(" ", 16-authorlen)."1.0                     Original")
    call append(20, "// ")
    call append(21, "// -FHDR----------------------------------------------------------------------------")
    call cursor(11,10)

endfunction "}}}3

function AlBpp() "{{{3
    let lnum = line(".")
    for idx in range(1,8)
        call append(lnum,"")
    endfor
    call setline(lnum+1,"    always@(posedge clk or posedge rst)")
    call setline(lnum+2,"    begin")
    call setline(lnum+3,"        if(rst)begin")
    call setline(lnum+4,"             ")
    call setline(lnum+5,"        end")
    call setline(lnum+6,"        else begin")
    call setline(lnum+7,"             ")
    call setline(lnum+8,"        end")
    call setline(lnum+9,"    end")
    call cursor(lnum+4,13)
endfunction "}}}3

function AlBpn() "{{{3
    let lnum = line(".")
    for idx in range(1,11)
        call append(lnum,"")
    endfor
    call setline(lnum+1 ,"    always@(posedge clk or negedge rst_n)")
    call setline(lnum+2 ,"    begin")
    call setline(lnum+3 ,"        if(!rst_n)begin")
    call setline(lnum+4 ,"            ")
    call setline(lnum+5 ,"        end ")
    call setline(lnum+6 ,"        else if()begin")
    call setline(lnum+7 ,"            ")
    call setline(lnum+8 ,"        end") 
    call setline(lnum+9 ,"        else begin")
    call setline(lnum+10,"            ")
    call setline(lnum+11,"        end")
    call setline(lnum+12,"    end")
    call cursor(lnum+3,13)
endfunction "}}}3

function AlB() "{{{3
    let lnum = line(".")
    for idx in range(1,3)
        call append(lnum,"")
    endfor
    call setline(lnum+1 ,"    always@(*)")
    call setline(lnum+2 ,"    begin")
    call setline(lnum+3 ,"        ")
    call setline(lnum+4 ,"    end")
    call cursor(lnum+2,9)
endfunction "}}}3

function AlBnn() "{{{3
    let lnum = line(".")
    for idx in range(1,11)
        call append(lnum,"")
    endfor
    call setline(lnum+1 ,"    always@(negedge clk or negedge rst_n)")
    call setline(lnum+2 ,"    begin")
    call setline(lnum+3 ,"        if(!rst_n) begin")
    call setline(lnum+4 ,"            ")
    call setline(lnum+5 ,"        end")
    call setline(lnum+6 ,"        else if()begin")
    call setline(lnum+7 ,"            ")
    call setline(lnum+8 ,"        end")
    call setline(lnum+9 ,"        else begin")
    call setline(lnum+10,"            ")
    call setline(lnum+11,"        end")
    call setline(lnum+12,"    end")
    call cursor(lnum+3,13)
endfunction "}}}3

function AlBp() "{{{3
    let lnum = line(".")
    for idx in range(1,8)
        call append(lnum,"")
    endfor
    call setline(lnum+1,"    always@(posedge clk)")
    call setline(lnum+2,"    begin")
    call setline(lnum+3,"        if()begin")
    call setline(lnum+4,"            ")
    call setline(lnum+5,"        end")
    call setline(lnum+6,"        else begin")
    call setline(lnum+7,"            ")
    call setline(lnum+8,"        end")
    call setline(lnum+9,"    end")
    call cursor(lnum+3,13)
endfunction "}}}3

function AlBn() "{{{3
    let lnum = line(".")
    for idx in range(1,8)
        call append(lnum,"")
    endfor
    call setline(lnum+1,"    always@(negedge clk)")
    call setline(lnum+2,"    begin")
    call setline(lnum+3,"        if()begin")
    call setline(lnum+4,"            ")
    call setline(lnum+5,"        end")
    call setline(lnum+6,"        else begin")
    call setline(lnum+7,"            ")
    call setline(lnum+8,"        end")
    call setline(lnum+9,"    end")
    call cursor(lnum+3,13)
endfunction "}}}3

function AutoComment() "{{{3
    let lnum = line(".")
    let line = getline(lnum)

    if line =~ '^\/\/ by .* \d\d\d\d-\d\d-\d\d'
        let tmp_line = substitute(line,'^\/\/ by .* \d\d\d\d-\d\d-\d\d | ','','')
    else
        let tmp_line = '// by ' . g:vimrc_author . ' ' . strftime("%Y-%m-%d") . ' | ' . line
    endif
    call setline(lnum,tmp_line)
endfunction "}}}3

function AutoComment2() "{{{3
    let col = col(".")
    let lnum = line(".")

    if line("'<") == lnum || line("'>") == lnum
        if getline(line("'<")) =~ '^/\*'
            '<
            execute "normal dd"
            '>
            execute "normal dd"
            if lnum != line("'<")
                let lnum = line("'>")-1
            endif
        else
            call append(line("'<")-1,'/*----------------  by '.g:vimrc_author.' '.strftime("%Y-%m-%d").'  ---------------------')
            call append(line("'>")  ,'------------------  by '.g:vimrc_author.' '.strftime("%Y-%m-%d").'  -------------------*/')
            let lnum = line(".")
        endif
    endif

    call cursor(lnum,col)

endfunction "}}}3

function AddCurLineComment() "{{{3
    let lnum = line(".")
    let line = getline(lnum)
    let tmp_line = line . ' // ' . g:vimrc_author . ' ' . strftime("%Y-%m-%d") . ' |'
    call setline(lnum,tmp_line)
    normal $
endfunction "}}}3

"}}}2

"Input2Output definition 转换input/output{{{2

function Input2Output() "{{{3
    let lnum = line(".")
    let line = getline(lnum)
    if line =~ '^\s*\/\/' || line =~ '^\s*$'
        return 0
    endif

    if line =~ '\<input\>\s\?'
        let line = substitute(line,'\<input\>\s\?','output','')
    elseif line =~ '\<output\>'
        let line = substitute(line,'\<output\>','input ','')
    endif

    call setline(lnum,line)
endfunction "}}}3

"}}}2

"}}}1

"Automatic 自动化功能{{{1

"Main Function 自动化主函数{{{2
"--------------------------------------------------
" Function: AutoInst
" Input: 
"   mode : mode for autoinst
" Description:
"   mode = 1, autoinst all instance
"   mode = 0, autoinst only one instance
" Output:
"   Formatted autoinst code
" Note:
"   list of port sequences
"            0     1        2       3       4       5            6          7
"   value = [type, sequnce, io_dir, width1, width2, signal_name, last_port, line ]
"   io_seqs = {seq : value }
"   io_names = {signal_name : value }
"---------------------------------------------------
function AutoInst(mode)
    "get file-dir dictionary & module-file dictionary
    let files = s:GetFileDirDicFromList(['.'],1)
    let modules = s:GetModuleFileDict(files)

    "put cursor to /*autoinst*/ line
    call cursor(line('.'),col('.'))

    "get module_name & inst_name
    let [module_name,inst_name,idx1,idx2] = s:GetInstModuleName()

    if module_name == '' || inst_name == ''
        echohl ErrorMsg | echo "Cannot find module_name or inst_name from line ".idx  | echohl None
    endif

    "get inst io list
    let keep_io_list = s:GetInstIO(getline(idx1,line('.')))
    let update_io_list = s:GetInstIO(getline(line('.'),idx2))

    "kill all contents under /*autoinst*/
    if a:mode == 0
        call s:KillAutoInst(0)
    elseif a:mode == 1
        call s:KillAutoInst(1)
    else
        echohl ErrorMsg | echo "Error input for AutoInst(),input mode =".a:mode| echohl None
    endif

    "get io sequences {seq : value}
    if has_key(modules,module_name)
        let file = modules[module_name]
        let dir = files[file]
        "read file
        let lines = readfile(dir.'/'.file)
        "io sequences
        let io_seqs = s:GetIO(lines,'seq')
        let io_names = s:GetIO(lines,'name')
    else
        echohl ErrorMsg | echo "file: ".module_name.".v does not exist in cur dir(" .$PWD. "/)"  | echohl None
    endif

    "remove io from io_seqs that want to be keep when autoinst
    "   value = [type, sequnce, io_dir, width1, width2, signal_name, last_port, line ]
    "   io_seqs = {seq : value }
    "   io_names = {signal_name : value }
    for name in keep_io_list
        if has_key(io_names,name)
            let value = io_names[name]
            let seq = value[1]
            call remove(io_seqs,seq)
        endif
    endfor


    call s:DrawIO(io_seqs)

endfunction
"}}}2

"Sub Function 辅助函数{{{2

"Get 
"GetIO 获取输入输出端口{{{3
"--------------------------------------------------
" Function: GetIO
" Input: 
"   lines : all lines to get IO port
"   mode : different use of keys
"          seq -> use seq as key
"          name -> use signal_name as key
" Description:
"   Get io port info from declaration
"   e.g
"   module_name #(
"       .A_PARAMETER (A_PARAMETER)
"       .B_PARAMETER (B_PARAMETER)
"   )
"   (
"       input       clk,
"       input       rst,
"       input       port_a,
"       output reg  port_b_valid,
"       output reg [31:0] port_b
"   );
"   e.g io port sequences
"   [io_wire,1,input,'c0','c0',clk,0,'       input       clk,']
"   [io_reg,5,output,31,0,port_b,0,'    output reg [31:0] port_b']
" Output:
"   list of port sequences(including comment lines)
"    0     1        2       3       4       5            6          7
"   [type, sequnce, io_dir, width1, width2, signal_name, last_port, line ]
"---------------------------------------------------
function s:GetIO(lines,mode)
    let idx = 0
    let seq = 0
    let wait_module = 1
    let wait_port = 1
    let io_seqs = {}
    while idx < len(a:lines)
        let idx = idx + 1
        let idx = s:SkipCommentLine(2,idx,a:lines)  "skip pair comment line
        let line = a:lines[idx-1]

        "find module first
        if line =~ '^\s*module'
            let wait_module = 0
        endif

        "until module,skip
        if wait_module == 1
            continue
        endif

        "no port definition, never record io_seqs
        if wait_port == 1 && line =~ ')\s*;' && len(io_seqs) > 0
            let seq = 0
            let io_seqs = {}
        endif

        if wait_module == 0
            "null line
            if line =~ '^\s*$'
                "if two adjacent lines are both null lines, delete last line
                if has_key(io_seqs,seq)
                    let value = io_seqs[seq]
                    if value[0] == 'keep' && value[7] =~ '^\s*$' && line =~ '^\s*$'
                        let idx = idx + 1
                        continue
                    endif
                endif
                "record first null line
                "           [type,  sequnce, io_dir, width1, width2, signal_name, last_port, line ]
                let value = ['keep',seq,     '',     'c0',   'c0',   '',          0,         '']
                call extend(io_seqs, {seq : value})
                let seq = seq + 1
            " `ifdef `ifndef & single comment line
            elseif line =~ '^\s*\`\(if\|else\|endif\)' || (line =~ '^\s*\/\/' && line !~ '^\s*\/\/\s*{{{')
                "           [type,  sequnce, io_dir, width1, width2, signal_name, last_port, line ]
                let value = ['keep',seq,     '',     'c0',   'c0',   line,        0,         line]
                call extend(io_seqs, {seq : value})
                let seq = seq + 1
            "}}}
            " input/output ports
            elseif line =~ '^\s*'. s:VlogTypePorts
                let wait_port = 0
                "delete abnormal
                if line =~ '\<signed\>\|\<unsigned\>'
                    let line = substitute(line,'\<signed\>\|\<unsigned\>','','')
                endif

                "type reg/wire
                let type = 'wire'
                if line =~ '\<reg\>'
                    let type = 'reg'
                endif
                "io direction input/output/inout
                let io_dir = matchstr(line,s:VlogTypePorts)

                "width
                let width = matchstr(line,'\[.*\]')                 
                let width = substitute(width,'\s*','','g')          "delete redundant space
                let width1 = matchstr(width,'\v\[\zs\w+\ze:.*\]')   
                let width2 = matchstr(width,'\v\[.*:\zs\w+\ze\]')   

                if width1 == ''
                    let width1 = 'c0'
                endif
                if width2 == ''
                    let width2 = 'c0'
                endif

                "name
                let line = substitute(line,io_dir,'','')
                let line = substitute(line,type,'','')
                let line = substitute(line,'\[.*:.*\]','','')
                let name = matchstr(line,'\w\+')

                "           [type,sequnce, io_dir, width1, width2, signal_name, last_port, line ]
                let value = [type,seq,     io_dir, width1, width2, name, 0,         '']
                call extend(io_seqs, {seq : value})
                let seq = seq + 1
            else
            endif

            "abnormal break
            if line =~ '^\s*\<always\>' || line =~ '^\s*\<assign\>' || line =~ '^\s*\<endmodule\>' || line =~ '\<autodef\>'
                break
            endif

        endif
    endwhile

    "find last_port
    let seq = len(io_seqs)
    while seq >= 0
        let seq = seq - 1
        if has_key(io_seqs,seq)
            let value = io_seqs[seq]
            let type = value[0]
            if type !~ 'keep'
                let value[7] = 1
                call remove(io_seqs,seq)
                call extend(io_seqs,{seq:value})
                break
            end
        endif
    endwhile

    "remove last useless line
    let seq = len(io_seqs)
    while seq >= 0
        let seq = seq - 1
        if has_key(io_seqs,seq)
            let value = io_seqs[seq]
            let type = value[0]
            let line = value[7]
            if type !~ 'keep' || line !~ '^\s*$'
                break
            else
                call remove(io_seqs,seq)
            end
        endif
    endwhile

    "remove first useless line
    let seq = 0
    while seq <= len(io_seqs)
        let seq = seq + 1
        if has_key(io_seqs,seq)
            let value = io_seqs[seq]
            let type = value[0]
            let line = value[7]
            if type !~ 'keep' || line !~ '^\s*$'
                break
            else
                call remove(io_seqs,seq)
            end
        endif
    endwhile

    if a:mode == 'seq'
        return io_seqs
    elseif a:mode == 'name'
        let io_names = {}
        for seq in keys(io_seqs)
            let value = io_seqs[seq]
            let name = value[5]
            if name !~ 'keep'
                call extend(io_names,{name:value})
            endif
        endfor
        return io_names
    else
        echohl ErrorMsg | echo "Error mode input for function GetIO! mode = ".a:mode| echohl None
    endif

endfunction
"}}}3

"GetInstIO 获取例化端口{{{3
"--------------------------------------------------
" Function: GetInstIO
" Input: 
"   lines : lines to get inst IO port
" Description:
"   Get inst io port info from lines
"   e.g_1
"   module_name #(
"       .A_PARAMETER (A_PARAMETER)
"       .B_PARAMETER (B_PARAMETER)
"   )
"   inst_name
"   (
"       .clk(clk),
"       .rst(rst),
"       /*autoinst*/
"       .port_a(port_a),
"       .port_b_valid(port_b_valid),
"       .port_b(port_b)
"   );
"
"   e.g_2
"   (.clk(clk),
"    .rst(rst),
"    /*autoinst*/
"    .port_a(port_a),
"    .port_b_valid(port_b_valid),
"    .port_b(port_b)
"   );
"
" Output:
"   list of port sequences(according to input lines)
"   e.g_1
"   inst_io_list = ['clk','rst']
"   e.g_2
"   inst_io_list = ['port_a','port_b_valid','port_b']
"---------------------------------------------------
function s:GetInstIO(lines)
    let idx = 0
    let inst_io_list = []
    while idx < len(a:lines)
        let idx = idx + 1
        let idx = s:SkipCommentLine(2,idx,a:lines)  "skip pair comment line
        let line = a:lines[idx-1]
        if line =~ '\.\s*\w\+\s*(.*)'
            let port = matchstr(line,'\.\s*\zs\w\+\ze\s*(.*)')
            call add(inst_io_list,port)
        endif
    endwhile
    return inst_io_list
endfunction
"}}}3

"GetInstModuleName 获取模块名和例化名{{{3
"--------------------------------------------------
" Function: GetInstModuleName
" Input: 
"   Must put cursor to /*autoinst*/ position
" Description:
" e.g
"   module_name #(
"       .A_PARAMETER (A_PARAMETER)
"       .B_PARAMETER (B_PARAMETER)
"   )
"   inst_name
"   (
"       ......
"       /*autoinst*/
"       ......
"   );
" Output:
"   module_name and inst_name
"   idx1: line index of inst_name
"   idx2: line index of );
"---------------------------------------------------
function s:GetInstModuleName()
    "record original idx & col to cursor back to orginal place
    let orig_idx = line('.')
    let orig_col = col('.')

    "get module_name & inst_name by search function
    let idx = line('.')
    let inst_name = ''
    let module_name= ''
    let wait_module_name = 0
    while 1
        "skip function must have lines input
        let idx = s:SkipCommentLine(1,idx,getline(1,line('$')))
        if idx == -1
                echohl ErrorMsg | echo "Error when SkipCommentLine!,return -1"| echohl None
        endif
        "afer skip, still use current buffer
        let line = getline(idx)

        "get inst_name
        if line =~ '('
            "find position of '('
            let col = match(line,'(')
            call cursor(idx,col+1)
            "search for pair ()
            if searchpair('(','',')') > 0
                let index = line('.')
                let col = col('.')
            else
                echohl ErrorMsg | echo "() pair not-match in autoinst, line: ".index." colunm: ".col | echohl None
            endif
            "search for next none-blank character
            call search('\S')
            "if it is ';' then pair
            if getline('.')[col('.')-1] == ';'
                "place cursor back to where ')' pair
                call cursor(index,col)

                "record ); position
                let idx2 = line('.')

                call searchpair('(','',')','bW')
                "find position of inst_name
                call search('\w\+','b')
                "get inst_name
                execute "normal! \"yye"
                let inst_name = getreg("y")

                "record inst_name position
                let idx1 = line('.')

                let wait_module_name = 1
            endif
        endif

        "get module_name
        if wait_module_name == 1
            "search for last none-blank character
            call search('\S','bW')
            "parameter exists
            if getline('.')[col('.')-1] == ')'
                if searchpair('(','',')','bW') > 0
                    let index = line('.')
                    let col = col('.')
                else
                    echohl ErrorMsg | echo "() pair not-match in parameter, line: ".index." colunm: ".col | echohl None
                endif
                call search('\w\+','bW')
            else
                call search('\w\+','bW')
            endif
            execute "normal! \"yye"
            let module_name = getreg("y")
            break
        endif

        "abnormal break
        if idx == 0 || getline(idx) =~ '^\s*module' || getline(idx) =~ ');' || getline(idx) =~ '(.*)\s*;'
            break
        else
            let idx = idx -1
        endif

    endwhile

    "cursor back
    call cursor(orig_idx,orig_col)

    return [module_name,inst_name,idx1,idx2]

endfunction
"}}}3

"GetFileDirDict 获取文件名文件夹关系{{{3

"--------------------------------------------------
" Function : GetFileDirDicFromList
" Input: 
"   dirlist: directory list
"   rec: recursively
" Description:
"   get file-dir dictionary from dirlist
" Output:
"   files  : file-dir dictionary(.v file)
"          e.g  ALU.v -> ./hdl/core
"---------------------------------------------------
function s:GetFileDirDicFromList(dirlist,rec)
    let files = {}
    for dir in a:dirlist
        let files = s:GetFileDirDic(dir,a:rec,files)
    endfor
    return files
endfunction

"--------------------------------------------------
" Function: GetFileDirDic
" Input: 
"   dir : directory
"   rec : recursive
"   files : dictionary to store
" Description:
"   rec = 1, recursively get inst-file dictionary (.v file) 
"   rec = 0, normally get inst-file dictionary (.v file)
" Output:
"   files : files-directory dictionary(.v file)
"---------------------------------------------------
function s:GetFileDirDic(dir,rec,files)
    let filelist = readdir(a:dir,{n -> n =~ '.v$'})
    for file in filelist
        call extend (a:files,{file : a:dir})
    endfor
    if a:rec
        for item in readdir(a:dir)
            if isdirectory(a:dir.'/'.item)
                call s:GetFileDirDic(a:dir.'/'.item,1,a:files)
            endif
        endfor
    endif
    return a:files
endfunction

"}}}3

"GetModuleFileDict 获取模块名和文件名关系{{{3
"--------------------------------------------------
" Function : GetModuleFileDict
" Input: 
"   files: file-dir dictionary
"          e.g  ALU.v -> ./hdl/core
" Description:
"   get module-file dictionary from file-dir dictionary
" Output:
"   modules: module-file dictionary
"          e.g  ALU -> ALU.v
"---------------------------------------------------
function s:GetModuleFileDict(files)
    let modules = {}
    for file in keys(a:files)
        let dir = a:files[file]
        "find module in ./hdl/core/ALU.v
        let lines = readfile(dir.'/'.file)  
        let module = ''
        for line in lines
            if line =~ '^\s*module\s*\w\+'
                let module = matchstr(line,'^\s*module\s*\zs\w\+')
                break
            endif
        endfor
        if module == ''
            call extend(modules,{'' : file})
        else
            call extend(modules,{module : file})
        endif
    endfor
    return modules
endfunction
"}}}3

"Kill  
"KillAutoInst 删除所有输入输出端口例化"{{{3
"--------------------------------------------------
" Function: KillIO
" Input: 
"   mode : mode for kill one autoinst or all autoinst
"          0 -> only kill one autoinst
"          1 -> kill all autoinst
" Description:
" e.g kill all declaration after /*autoinst*/
"   mode = 0
"    
"   module_name
"   inst_name
"   (   
"       .clk        (clk),      //input
"       /*autoinst*/
"       .port_b     (port_b)    //output
"   );
"   
"   --------------> after KillAutoInst
"
"   module_name
"   inst_name
"   (   
"       .clk        (clk),      //input
"       /*autoinst*/);
"
" Output:
"   line after kill
"---------------------------------------------------
function s:KillAutoInst(mode) 
    if a:mode == 1
        let idx = 0
    else
        let idx = line('.')
    endif
    let kill = 0
    let multi = 0
    while idx < line('$')
        let line = getline(idx)
        if line =~ '/\*\<autoinst\>'
            let kill = 1
            "if current line end with ');', one line
            if line =~');\s*$'
                break
            else
                let multi = 1
            endif
            "keep current line
            let line = substitute(line,'\*/.*$','\*/);','')
            call setline(idx,line)
            "if current line not end with ');', multi-line
            if multi == 1
                let idx = idx + 1
                while 1
                    let line = getline(idx)
                    "end of inst
                    if line =~ ');\s*$'
                        call deletebufline('%',idx)
                        break
                    "abnormal end
                    elseif line =~ 'endmodule' || idx == line('$')
                        echohl ErrorMsg | echo "Error running KillAutoInst! Kill abnormally till the end!"| echohl None
                        break
                    "middle
                    else
                        call deletebufline('%',idx)
                    endif
                endwhile
            endif
        endif
        "mode 0, only run once
        if a:mode == 0 && kill == 1
            break
        endif 
        let idx = idx + 1
    endwhile
endfunction "}}}3

"Draw 
"DrawIO 按格式输出例化IO口{{{3
"--------------------------------------------------
" Function: DrawIO
" Input: 
"   io_seqs : inst io for align
" Description:
" e.g draw io port sequences
"   [io_wire,1,input,'c0','c0',clk,0,'       input       clk,']
"   [io_reg,5,output,31,0,port_b,0,'    output reg [31:0] port_b']
"   module_name
"   inst_name
"   (
"       .clk        (clk),      //input
"       .port_b     (port_b)    //output
"   );
"
" Output:
"   line that's aligned
"   e.g
"       .signal_name   (signal_name[width1:width2]      ), //io_dir
"---------------------------------------------------
function s:DrawIO(io_seqs)
    let prefix = repeat(' ',4)

    "guarantee spaces width
    let max_lbracket_len = 0
    let max_rbracket_len = 0
    for seq in sort(keys(a:io_seqs),'N')
        let value = a:io_seqs[seq]
        let type = value[0]
        if type != 'keep' 
            let name = value[5]
            if value[3] == 'c0' || value[4] == 'c0'
                let width = ''
            else
                let width = '['.value[3].':'.value[4].']'
            endif
            let max_lbracket_len = max([max_lbracket_len,len(prefix)+len(name)+4,s:max_pos_name])
            let max_rbracket_len = max([max_rbracket_len,max_lbracket_len+1+len(name)+len(width)+4,s:max_pos_symbol])
        endif
    endfor

    "Draw IO
    let lines = []
    for seq in sort(keys(a:io_seqs),'N')
        let value = a:io_seqs[seq]
        let type = value[0]
        let line = value[7]
        "add single line comment line
        if type == 'keep' && line =~ '^\s*\/\/'
            let line = prefix.line
            call add(lines,line)
        else
            "   [type, sequnce, io_dir, width1, width2, signal_name, last_port, line ]
            "name
            let name = value[5]
            "name2bracket
            let name2bracket = repeat(' ',max_lbracket_len-len(prefix)-len(name)-4)
            "width
            if value[3] == 'c0' || value[4] == 'c0'
                let width = ''
            else
                let width = '['.value[3].':'.value[4].']'
            endif
            "width2bracket
            let width2bracket = repeat(' ',max_rbracket_len-max_lbracket_len-1-len(name)-len(width)-4)
            "comma
            let last_port = value[6]
            if last_port == 1
                let comma = ','      "comma exists
            else
                let comma = ' '      "space
            endif
            "io_dir
            let io_dir = value[2]

            let line = prefix.'.'.name.name2bracket.'('.name.width.width2bracket.')'.comma.' //'.io_dir
            call add(lines,line)
        endif
    endfor

    for line in lines
        echo line
    endfor
    return lines

endfunction
"}}}3

"Others
"SkipCommentLine 跳过注释行{{{3
"--------------------------------------------------
" Function: SkipCommentLine
" Input: 
"   mode : mode for search up/down
"          0 -> search down
"          1 -> search up
"          2 -> search down, but ignore //......
"          3 -> search up, but ignore //......
"   idx  : start line index of searching
"   lines: content of lines for searching 
" Description:
"   Skip comment line of 
"       1. //..........
"       2. /*......
"            ......
"            ......*/
"       3. ignore comment line of /*....*/
"          since it might be /*autoinst*/
" Output:
"   next line index that's not a comment line
"---------------------------------------------------
function s:SkipCommentLine(mode,idx,lines)
    let comment_pair = 0
    if a:mode == 0
        let start_pattern = '^\s*/\*'
        let start_symbol = '\*/'
        let end_pattern = '\*/\s*$'
        let end_symbol = '/\*'
        let single_pattern = '^\s*\/\/'
        let end = len(a:lines)
        let stride = 1
    elseif a:mode == 1
        let start_pattern = '\*/\s*$'
        let start_symbol = '/\*'
        let end_pattern = '^\s*/\*'
        let end_symbol = '\*/'
        let single_pattern = '^\s*\/\/'
        let end = 1
        let stride = -1
    elseif a:mode == 2
        let start_pattern = '^\s*/\*'
        let start_symbol = '\*/'
        let end_pattern = '\*/\s*$'
        let end_symbol = '/\*'
        let single_pattern = 'HonkW is always is most handsome man!'
        let end = len(a:lines)
        let stride = 1
    elseif a:mode == 3
        let start_pattern = '\*/\s*$'
        let start_symbol = '/\*'
        let end_pattern = '^\s*/\*'
        let end_symbol = '\*/'
        let single_pattern = 'HonkW is always is most handsome man!'
        let end = 1
        let stride = -1
    else
        echohl ErrorMsg | echo "Error mode input for function SkipCommentLine! mode = ".a:mode| echohl None
    endif

    for idx in range(a:idx,end,stride)
        let line = a:lines[idx-1]
        "/* symbol at top of the line
        if line =~ start_pattern  && line !~ start_symbol
            let comment_pair = 1
            continue
        "*/ symbol at end of the line
        elseif line =~ end_pattern && line !~ end_symbol
            let comment_pair = 0
            continue
        elseif comment_pair == 1        "comment pair /* ... */
            continue
        elseif line =~ single_pattern   "comment line //
            continue
        else                            "not comment, return
            return idx
        endif
    endfor

    return -1
endfunction
"}}}3

"}}}2

"}}}1

function VlogTest()
    let line = getline('.')
endfunction


