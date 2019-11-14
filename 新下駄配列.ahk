#Include  %A_ScriptDir%\IME.ahk

;=============================
; タイマー入り 同時打鍵スクリプト
;　　+ IME 状態チェック IME.ahk 利用バージョン
; 「http://kohada.2ch.net/test/read.cgi/pc/1201883108/199,282
; の199氏の作ったahk版下駄配列スクリプトの配列を入れ替えただけの新下駄配列版。
; ヴァ行などをそのまま使いたかったので下駄にあって新下駄に無い配列もそのま」
; の改造版
;
; [注意] 
; Ctrl+Esc でスクリプトの停止・再開ができます
; Ctrl+F12 でタイピングモードの切り替えができます
;=============================

; メニュー追加
Menu, Tray, Add
Menu, Tray, Add, ローマ字入力, Menu_Rome
Menu, Tray, Add, かな入力, Menu_Kana
Menu, Tray, Add
Menu, Tray, Add, タイピングモード, Menu_Typing
Menu, Tray, Icon, %A_ScriptDir%\ShinGeta_on.ico , ,1


global MenuTypingValue:=0
Menu, Tray, Uncheck, タイピングモード

Menu_Typing(){
  if(MenuTypingValue = 1){
    Menu, Tray, Uncheck, タイピングモード
    MenuTypingValue:=0
  }else{
    Menu, Tray, Check, タイピングモード
    MenuTypingValue:=1
  }
}

global RomeKana:=0
IniRead, RomeKana, %A_ScriptDir%\新下駄配列.ini, main, RomeKana

Menu_Rome(){
	Menu, Tray, Check, ローマ字入力
	Menu, Tray, Uncheck, かな入力
	RomeKana:=0
	SetInputDef()
}
Menu_Kana(){
	Menu, Tray, Uncheck, ローマ字入力
	Menu, Tray, Check, かな入力
	RomeKana:=1
	SetInputDef()
}
Menu_InitialRomeKana(){
  if(RomeKana = 0){
	Menu, Tray, Check, ローマ字入力
	Menu, Tray, Uncheck, かな入力
  }else{
	Menu, Tray, Uncheck, ローマ字入力
	Menu, Tray, Check, かな入力
  }
}

; Maximal Gap Time は同時打鍵判定用の時定数です
; この時間(ms)内に次の入力があった場合は「同時」と見なします
global MaximalGT:=70
IniRead, MaximalGT, %A_ScriptDir%\新下駄配列.ini, main, MaximalGT

; Single Key Wait はキーを押してからタイマーで確定するまでの時間です
global SingleKeyWait:=MaximalGT

; キー関連グローバル変数定義↓-------------------------------------

; キーバッファ
; bufKey には _Q のような名前（文字列）が格納されます
; bufTime はキーが押された時刻です

global bufKey:=0
global bufTime:=0
global gDownKeyName:=0

; 以下は IME がローマ字モードじゃないときに出力する文字です
global defaultKey_Q:="q"
global defaultKey_W:="w"
global defaultKey_E:="e"
global defaultKey_R:="r"
global defaultKey_T:="t"
global defaultKey_Y:="y"
global defaultKey_U:="u"
global defaultKey_I:="i"
global defaultKey_O:="o"
global defaultKey_P:="p"
global defaultKey_AT:="@"
global defaultKey_A:="a"
global defaultKey_S:="s"
global defaultKey_D:="d"
global defaultKey_F:="f"
global defaultKey_G:="g"
global defaultKey_H:="h"
global defaultKey_J:="j"
global defaultKey_K:="k"
global defaultKey_L:="l"
global defaultKey_SColon:=";"
global defaultKey_Colon:=":"
global defaultKey_Z:="z"
global defaultKey_X:="x"
global defaultKey_C:="c"
global defaultKey_V:="v"
global defaultKey_B:="b"
global defaultKey_N:="n"
global defaultKey_M:="m"
global defaultKey_Comma:=","
global defaultKey_Dot:="."
global defaultKey_Slash:="/"
global defaultKey_1:="1"
global defaultKey_2:="2"
global defaultKey_3:="3"
global defaultKey_4:="4"
global defaultKey_5:="5"
global defaultKey_6:="6"
global defaultKey_7:="7"
global defaultKey_8:="8"
global defaultKey_9:="9"
global defaultKey_0:="0"
global defaultKey_Hiphen:="-"
global defaultKey_LBracket:="["
global defaultKey_RBracket:="]"
global defaultKey_Hat:="^"
global defaultKey_Pipe:="|"
global defaultKey_BackSlash:="\"

; 各キーに同時打鍵判定のための識別フラグをわりあてます
global flag_Q:=1
global flag_W:=1<<1
global flag_E:=1<<2
global flag_R:=1<<3
global flag_T:=1<<4
global flag_Y:=1<<5
global flag_U:=1<<6
global flag_I:=1<<7
global flag_O:=1<<8
global flag_P:=1<<9
global flag_A:=1<<10
global flag_S:=1<<11
global flag_D:=1<<12
global flag_F:=1<<13
global flag_G:=1<<14
global flag_H:=1<<15
global flag_J:=1<<16
global flag_K:=1<<17
global flag_L:=1<<18
global flag_SColon:=1<<19
global flag_Z:=1<<20
global flag_X:=1<<21
global flag_C:=1<<22
global flag_V:=1<<23
global flag_B:=1<<24
global flag_N:=1<<25
global flag_M:=1<<26
global flag_Comma:=1<<27
global flag_Dot:=1<<28
global flag_Slash:=1<<30
global flag_AT:=1<<31
global flag_Colon:=1<<32
global flag_Home:=1<<33
global flag_End:=1<<34
global flag_1:=1<<35
global flag_2:=1<<36
global flag_3:=1<<37
global flag_4:=1<<38
global flag_5:=1<<39
global flag_6:=1<<40
global flag_7:=1<<41
global flag_8:=1<<42
global flag_9:=1<<43
global flag_0:=1<<44
global flag_Hiphen:=1<<45
global flag_RBracket:=1<<46
global flag_Colon:=1<<47
global flag_LBracket:=1<<48
global flag_Hat:=1<<49
global flag_Pipe:=1<<50
global flag_BackSlash:=1<<51

; シングルストロークでsendする文字列
global singleStroke_Q:=0
global singleStroke_W:=0
global singleStroke_E:=0
global singleStroke_R:=0
global singleStroke_T:=0
global singleStroke_Y:=0
global singleStroke_U:=0
global singleStroke_I:=0
global singleStroke_O:=0
global singleStroke_P:=0
global singleStroke_AT:=0
global singleStroke_A:=0
global singleStroke_S:=0
global singleStroke_D:=0
global singleStroke_F:=0
global singleStroke_G:=0
global singleStroke_H:=0
global singleStroke_J:=0
global singleStroke_K:=0
global singleStroke_L:=0
global singleStroke_SColon:=0
global singleStroke_Z:=0
global singleStroke_X:=0
global singleStroke_C:=0
global singleStroke_V:=0
global singleStroke_B:=0
global singleStroke_N:=0
global singleStroke_M:=0
global singleStroke_Comma:=0
global singleStroke_Dot:=0
global singleStroke_Slash:=0
global singleStroke_1:=0
global singleStroke_2:=0
global singleStroke_3:=0
global singleStroke_4:=0
global singleStroke_5:=0
global singleStroke_6:=0
global singleStroke_7:=0
global singleStroke_8:=0
global singleStroke_9:=0
global singleStroke_0:=0
global singleStroke_Hiphen:=0
global singleStroke_LBracket:=0
global singleStroke_RBracket:=0
global singleStroke_Colon:=0
global singleStroke_Hat:=0
global singleStroke_Pipe:=0
global singleStroke_BackSlash:=0


; 同時打鍵でsendする文字列
global kCmb1:=0
global resultOfKCmb1:=0
global kCmb2:=0
global resultOfKCmb2:=0
global kCmb3:=0
global resultOfKCmb3:=0
global kCmb4:=0
global resultOfKCmb4:=0
global kCmb5:=0
global resultOfKCmb5:=0
global kCmb6:=0
global resultOfKCmb6:=0
global kCmb7:=0
global resultOfKCmb7:=0
global kCmb8:=0
global resultOfKCmb8:=0
global kCmb9:=0
global resultOfKCmb9:=0
global kCmb10:=0
global resultOfKCmb10:=0
global kCmb11:=0
global resultOfKCmb11:=0
global kCmb12:=0
global resultOfKCmb12:=0
global kCmb13:=0
global resultOfKCmb13:=0
global kCmb14:=0
global resultOfKCmb14:=0
global kCmb15:=0
global resultOfKCmb15:=0
global kCmb16:=0
global resultOfKCmb16:=0
global kCmb17:=0
global resultOfKCmb17:=0
global kCmb18:=0
global resultOfKCmb18:=0
global kCmb19:=0
global resultOfKCmb19:=0
global kCmb20:=0
global resultOfKCmb20:=0
global kCmb21:=0
global resultOfKCmb21:=0
global kCmb22:=0
global resultOfKCmb22:=0
global kCmb23:=0
global resultOfKCmb23:=0
global kCmb24:=0
global resultOfKCmb24:=0
global kCmb25:=0
global resultOfKCmb25:=0
global kCmb26:=0
global resultOfKCmb26:=0
global kCmb27:=0
global resultOfKCmb27:=0
global kCmb28:=0
global resultOfKCmb28:=0
global kCmb29:=0
global resultOfKCmb29:=0
global kCmb30:=0
global resultOfKCmb30:=0
global kCmb31:=0
global resultOfKCmb31:=0
global kCmb32:=0
global resultOfKCmb32:=0
global kCmb33:=0
global resultOfKCmb33:=0
global kCmb34:=0
global resultOfKCmb34:=0
global kCmb35:=0
global resultOfKCmb35:=0
global kCmb36:=0
global resultOfKCmb36:=0
global kCmb37:=0
global resultOfKCmb37:=0
global kCmb38:=0
global resultOfKCmb38:=0
global kCmb39:=0
global resultOfKCmb39:=0
global kCmb40:=0
global resultOfKCmb40:=0
global kCmb41:=0
global resultOfKCmb41:=0
global kCmb42:=0
global resultOfKCmb42:=0
global kCmb43:=0
global resultOfKCmb43:=0
global kCmb44:=0
global resultOfKCmb44:=0
global kCmb45:=0
global resultOfKCmb45:=0
global kCmb46:=0
global resultOfKCmb46:=0
global kCmb47:=0
global resultOfKCmb47:=0
global kCmb48:=0
global resultOfKCmb48:=0
global kCmb49:=0
global resultOfKCmb49:=0
global kCmb50:=0
global resultOfKCmb50:=0
global kCmb51:=0
global resultOfKCmb51:=0
global kCmb52:=0
global resultOfKCmb52:=0
global kCmb53:=0
global resultOfKCmb53:=0
global kCmb54:=0
global resultOfKCmb54:=0
global kCmb55:=0
global resultOfKCmb55:=0
global kCmb56:=0
global resultOfKCmb56:=0
global kCmb57:=0
global resultOfKCmb57:=0
global kCmb58:=0
global resultOfKCmb58:=0
global kCmb59:=0
global resultOfKCmb59:=0
global kCmb60:=0
global resultOfKCmb60:=0
global kCmb61:=0
global resultOfKCmb61:=0
global kCmb62:=0
global resultOfKCmb62:=0
global kCmb63:=0
global resultOfKCmb63:=0
global kCmb64:=0
global resultOfKCmb64:=0
global kCmb65:=0
global resultOfKCmb65:=0
global kCmb76:=0
global resultOfKCmb76:=0
global kCmb77:=0
global resultOfKCmb77:=0
global kCmb78:=0
global resultOfKCmb78:=0
global kCmb79:=0
global resultOfKCmb79:=0
global kCmb80:=0
global resultOfKCmb80:=0
global kCmb81:=0
global resultOfKCmb81:=0
global kCmb82:=0
global resultOfKCmb82:=0
global kCmb83:=0
global resultOfKCmb83:=0
global kCmb84:=0
global resultOfKCmb84:=0
global kCmb85:=0
global resultOfKCmb85:=0
global kCmb86:=0
global resultOfKCmb86:=0
global kCmb87:=0
global resultOfKCmb87:=0
global kCmb88:=0
global resultOfKCmb88:=0
global kCmb141:=0
global resultOfKCmb141:=0
global kCmb142:=0
global resultOfKCmb142:=0
global kCmb143:=0
global resultOfKCmb143:=0
global kCmb144:=0
global resultOfKCmb144:=0
global kCmb145:=0
global resultOfKCmb145:=0
global kCmb147:=0
global resultOfKCmb147:=0
global kCmb148:=0
global resultOfKCmb148:=0
global kCmb149:=0
global resultOfKCmb149:=0
global kCmb150:=0
global resultOfKCmb150:=0
global kCmb151:=0
global resultOfKCmb151:=0
global kCmb152:=0
global resultOfKCmb152:=0
global kCmb153:=0
global resultOfKCmb153:=0
global kCmb155:=0
global resultOfKCmb155:=0
global kCmb157:=0
global resultOfKCmb157:=0
global kCmb158:=0
global resultOfKCmb158:=0
global kCmb159:=0
global resultOfKCmb159:=0
global kCmb160:=0
global resultOfKCmb160:=0
global kCmb161:=0
global resultOfKCmb161:=0
global kCmb162:=0
global resultOfKCmb162:=0
global kCmb163:=0
global resultOfKCmb163:=0
global kCmb164:=0
global resultOfKCmb164:=0
global kCmb165:=0
global resultOfKCmb165:=0
global kCmb166:=0
global resultOfKCmb166:=0
global kCmb167:=0
global resultOfKCmb167:=0
global kCmb168:=0
global resultOfKCmb168:=0
global kCmb169:=0
global resultOfKCmb169:=0
global kCmb170:=0
global resultOfKCmb170:=0
global kCmb171:=0
global resultOfKCmb171:=0
global kCmb172:=0
global resultOfKCmb172:=0
global kCmb173:=0
global resultOfKCmb173:=0
global kCmb174:=0
global resultOfKCmb174:=0
global kCmb175:=0
global resultOfKCmb175:=0
global kCmb176:=0
global resultOfKCmb176:=0
global kCmb177:=0
global resultOfKCmb177:=0
global kCmb178:=0
global resultOfKCmb178:=0
global kCmb179:=0
global resultOfKCmb179:=0
global kCmb180:=0
global resultOfKCmb180:=0
global kCmb181:=0
global resultOfKCmb181:=0
global kCmb182:=0
global resultOfKCmb182:=0
global kCmb183:=0
global resultOfKCmb183:=0
global kCmb184:=0
global resultOfKCmb184:=0
global kCmb185:=0
global resultOfKCmb185:=0
global kCmb186:=0
global resultOfKCmb186:=0
global kCmb187:=0
global resultOfKCmb187:=0
global kCmb188:=0
global resultOfKCmb188:=0
global kCmb189:=0
global resultOfKCmb189:=0
global kCmb190:=0
global resultOfKCmb190:=0
global kCmb191:=0
global resultOfKCmb191:=0
global kCmb192:=0
global resultOfKCmb192:=0
global kCmb193:=0
global resultOfKCmb193:=0
global kCmb194:=0
global resultOfKCmb194:=0
global kCmb195:=0
global resultOfKCmb195:=0
global kCmb196:=0
global resultOfKCmb196:=0
global kCmb197:=0
global resultOfKCmb197:=0
global kCmb198:=0
global resultOfKCmb198:=0
global kCmb199:=0
global resultOfKCmb199:=0
global kCmb200:=0
global resultOfKCmb200:=0
global kCmb201:=0
global resultOfKCmb201:=0
global kCmb202:=0
global resultOfKCmb202:=0
; 同時打鍵パターンの総数
global NumberOfKCmb:=202
; キー関連グローバル変数定義↑-------------------------------------

; 初期定義設定
Menu_InitialRomeKana()
SetInputDef()

SetInputDef(){
	if(RomeKana = 0){
		; ローマ字入力時の定義
		; 以下でシングルストロークで send する文字列を定義します
		singleStroke_Q=-	;ー
		singleStroke_W=ni	;に
		singleStroke_E=ha	;は
		singleStroke_R=`,	;,
		singleStroke_T=ti	;ち
		singleStroke_Y=gu	;ぐ
		singleStroke_U=ba	;ば
		singleStroke_I=ko	;こ
		singleStroke_O=ga	;が
		singleStroke_P=hi	;ひ
		singleStroke_AT=ge	;げ
		singleStroke_A=no	;の
		singleStroke_S=to	;と
		singleStroke_D=ka	;か
		singleStroke_F=nn	;ん
		singleStroke_G=ltu	;っ
		singleStroke_H=ku	;く
		singleStroke_J=u	;う
		singleStroke_K=i	;い
		singleStroke_L=si	;し
		singleStroke_SColon=na	;な
		singleStroke_Z=su	;す
		singleStroke_X=ma	;ま
		singleStroke_C=ki	;き
		singleStroke_V=ru	;る
		singleStroke_B=tu	;つ
		singleStroke_N=te	;て
		singleStroke_M=ta	;た
		singleStroke_Comma=de	;で
		singleStroke_Dot=.	;。
		singleStroke_Slash=bu	;ぶ
		singleStroke_1=1	;１
		singleStroke_2=2	;２
		singleStroke_3=3	;３
		singleStroke_4=4	;４
		singleStroke_5=5	;５
		singleStroke_6=6	;６
		singleStroke_7=7	;７
		singleStroke_8=8	;８
		singleStroke_9=9	;９
		singleStroke_0=0	;０
		singleStroke_Hiphen=-	;ー
		singleStroke_RBracket=]
		singleStroke_Colon={BackSpace}


		; 同時打鍵の定義
		; kCmb1:=flag_F|flag_J	; を
		; resultOfKCmb1=wo
		kCmb2:=flag_K|flag_Q	; ふぁ
		resultOfKCmb2=fa
		kCmb3:=flag_K|flag_W	; ご
		resultOfKCmb3=go
		kCmb4:=flag_K|flag_E	; ふ
		resultOfKCmb4=fu
		kCmb5:=flag_K|flag_R	; ふぃ
		resultOfKCmb5=fi
		kCmb6:=flag_K|flag_T	; ふぇ
		resultOfKCmb6=fe
		kCmb7:=flag_K|flag_A	; ほ
		resultOfKCmb7=ho
		kCmb8:=flag_K|flag_S	; じ
		resultOfKCmb8=ji
		kCmb9:=flag_K|flag_D	; れ
		resultOfKCmb9=re
		kCmb10:=flag_K|flag_F	; も
		resultOfKCmb10=mo
		kCmb11:=flag_K|flag_G	; ゆ
		resultOfKCmb11=yu
		kCmb12:=flag_K|flag_Z	; づ
		resultOfKCmb12=du
		kCmb13:=flag_K|flag_C	; ぼ
		resultOfKCmb13=bo
		kCmb14:=flag_K|flag_V	; む
		resultOfKCmb14=mu
		kCmb15:=flag_K|flag_B	; ふぉ
		resultOfKCmb15=fo
		kCmb16:=flag_D|flag_Y	; うぃ
		resultOfKCmb16=wi
		kCmb17:=flag_D|flag_U	; ぱ
		resultOfKCmb17=pa
		kCmb18:=flag_D|flag_I	; よ
		resultOfKCmb18=yo
		kCmb19:=flag_D|flag_O	; み
		resultOfKCmb19=mi
		kCmb20:=flag_D|flag_P	; うぇ
		resultOfKCmb20=we
		kCmb21:=flag_D|flag_H	; へ
		resultOfKCmb21=he
		kCmb22:=flag_D|flag_J	; あ
		resultOfKCmb22=a
		kCmb23:=flag_D|flag_SColon	; え
		resultOfKCmb23=e
		kCmb24:=flag_D|flag_N	; せ
		resultOfKCmb24=se
		kCmb25:=flag_D|flag_M	; ね
		resultOfKCmb25=ne
		kCmb26:=flag_D|flag_Comma	; べ
		resultOfKCmb26=be
		kCmb27:=flag_D|flag_Dot	; ぷ
		resultOfKCmb27=pu
		kCmb28:=flag_D|flag_Slash	; ヴ
		resultOfKCmb28=vu
		kCmb29:=flag_L|flag_W	; め
		resultOfKCmb29=me
		kCmb30:=flag_L|flag_E	; け
		resultOfKCmb30=ke
		kCmb31:=flag_L|flag_R	; てぃ
		resultOfKCmb31=texi
		kCmb32:=flag_L|flag_T	; でぃ
		resultOfKCmb32=dexi
		kCmb33:=flag_L|flag_A	; を
		resultOfKCmb33=wo
		kCmb34:=flag_L|flag_S	; さ
		resultOfKCmb34=sa
		kCmb35:=flag_L|flag_D	; お
		resultOfKCmb35=o
		kCmb36:=flag_L|flag_F	; り
		resultOfKCmb36=ri
		kCmb37:=flag_L|flag_G	; ず
		resultOfKCmb37=zu
		kCmb38:=flag_L|flag_Z	; ぜ
		resultOfKCmb38=ze
		kCmb39:=flag_L|flag_X	; ざ
		resultOfKCmb39=za
		kCmb40:=flag_L|flag_C	; ぎ
		resultOfKCmb40=gi
		kCmb41:=flag_L|flag_V	; ろ
		resultOfKCmb41=ro
		kCmb42:=flag_L|flag_B	; ぬ
		resultOfKCmb42=nu
		kCmb43:=flag_S|flag_U	; ぺ
		resultOfKCmb43=pe
		kCmb44:=flag_S|flag_I	; ど
		resultOfKCmb44=do
		kCmb45:=flag_S|flag_O	; や
		resultOfKCmb45=ya
		kCmb46:=flag_S|flag_H	; び
		resultOfKCmb46=bi
		kCmb47:=flag_S|flag_J	; ら
		resultOfKCmb47=ra
		kCmb48:=flag_S|flag_SColon	; そ
		resultOfKCmb48=so
		kCmb49:=flag_S|flag_N	; わ
		resultOfKCmb49=wa
		kCmb50:=flag_S|flag_M	; だ
		resultOfKCmb50=da
		kCmb51:=flag_S|flag_Comma	; ぴ
		resultOfKCmb51=pi
		kCmb52:=flag_S|flag_Slash	; ちぇ
		resultOfKCmb52=che
		kCmb53:=flag_I|flag_R	; きゅ
		resultOfKCmb53=kyu
		kCmb54:=flag_I|flag_F	; きょ
		resultOfKCmb54=kyo
		kCmb55:=flag_I|flag_V	; きゃ
		resultOfKCmb55=kya
		kCmb56:=flag_I|flag_T	; ちゅ
		resultOfKCmb56=cyu
		kCmb57:=flag_I|flag_G	; ちょ
		resultOfKCmb57=cyo
		kCmb58:=flag_I|flag_B	; ちゃ
		resultOfKCmb58=cya
		kCmb59:=flag_I|flag_A	; ひょ
		resultOfKCmb59=hyo
		kCmb60:=flag_I|flag_Z	; ひゃ
		resultOfKCmb60=hya
		kCmb61:=flag_I|flag_X	; くぇ
		resultOfKCmb61=qe
		kCmb62:=flag_I|flag_C	; しゃ
		resultOfKCmb62=sha
		kCmb63:=flag_I|flag_Q	; ひゅ
		resultOfKCmb63=hyu
		kCmb64:=flag_I|flag_W	; しゅ
		resultOfKCmb64=shu
		kCmb65:=flag_I|flag_E	; しょ
		resultOfKCmb65=syo
		kCmb76:=flag_O|flag_R	; ぎゅ
		resultOfKCmb76=gyu
		kCmb77:=flag_O|flag_F	; ぎょ
		resultOfKCmb77=gyo
		kCmb78:=flag_O|flag_V	; ぎゃ
		resultOfKCmb78=gya
		kCmb79:=flag_O|flag_T	; にゅ
		resultOfKCmb79=nyu
		kCmb80:=flag_O|flag_G	; にょ
		resultOfKCmb80=nyo
		kCmb81:=flag_O|flag_B	; にゃ
		resultOfKCmb81=nya
		kCmb82:=flag_O|flag_A	; りょ
		resultOfKCmb82=ryo
		kCmb83:=flag_O|flag_Z	; りゃ
		resultOfKCmb83=rya
		kCmb84:=flag_O|flag_X	; ぐぇ
		resultOfKCmb84=gwe
		kCmb85:=flag_O|flag_C	; じゃ
		resultOfKCmb85=ja
		kCmb86:=flag_O|flag_Q	; りゅ
		resultOfKCmb86=ryu
		kCmb87:=flag_O|flag_W	; じゅ
		resultOfKCmb87=ju
		kCmb88:=flag_O|flag_E	; じょ
		resultOfKCmb88=jo
		kCmb141:=flag_W|flag_E	; (
		resultOfKCmb141=(
		kCmb142:=flag_E|flag_R	; !
		resultOfKCmb142={!}
		kCmb143:=flag_E|flag_F	; ~
		resultOfKCmb143=,~
		kCmb144:=flag_R|flag_G	; ・
		resultOfKCmb144=/
		kCmb145:=flag_S|flag_D	; [
		resultOfKCmb145=[
		kCmb147:=flag_F|flag_G	; 「」
		resultOfKCmb147=[]{Enter}{Left}
		kCmb148:=flag_D|flag_V	; @
		resultOfKCmb148=@
		kCmb149:=flag_X|flag_C	; {
		resultOfKCmb149={{}
		kCmb150:=flag_C|flag_V	; ,
		resultOfKCmb150=`,
		kCmb151:=flag_U|flag_I	; ?
		resultOfKCmb151=?
		kCmb152:=flag_I|flag_O	; )
		resultOfKCmb152=)
		kCmb153:=flag_U|flag_H	; ／
		resultOfKCmb153=【】{Enter}{Left}
		kCmb155:=flag_H|flag_J	; （）
		resultOfKCmb155=+8+9{Enter}{Left}
		kCmb157:=flag_K|flag_L	; ]
		resultOfKCmb157=]
		kCmb158:=flag_K|flag_N	; \
		resultOfKCmb158=\
		kCmb159:=flag_M|flag_Comma	; ,
		resultOfKCmb159=`,
		kCmb160:=flag_Comma|flag_Dot	; ｝
		resultOfKCmb160={}}
		kCmb161:=flag_K|flag_X	; ぞ
		resultOfKCmb161=zo
		kCmb162:=flag_L|flag_Q	; ぢ
		resultOfKCmb162=di
		kCmb163:=flag_S|flag_Y	; しぇ
		resultOfKCmb163=she
		kCmb164:=flag_S|flag_Dot	; ぽ
		resultOfKCmb164=po
		kCmb165:=flag_S|flag_P	; じぇ
		resultOfKCmb165=je
		kCmb166:=flag_K|flag_1	; ぁ
		resultOfKCmb166=xa
		kCmb167:=flag_K|flag_2	; ぃ
		resultOfKCmb167=xi
		kCmb168:=flag_K|flag_3	; ぅ
		resultOfKCmb168=xu
		kCmb169:=flag_K|flag_4	; ぇ
		resultOfKCmb169=xe
		kCmb170:=flag_K|flag_5	; ぉ
		resultOfKCmb170=xo
		kCmb171:=flag_L|flag_1	; ゃ
		resultOfKCmb171=xya
		kCmb172:=flag_L|flag_2	; みゃ
		resultOfKCmb172=mya
		kCmb173:=flag_L|flag_3	; みゅ
		resultOfKCmb173=myu
		kCmb174:=flag_L|flag_4	; みょ
		resultOfKCmb174=myo
		kCmb175:=flag_L|flag_5	; ゎ
		resultOfKCmb175=xwa
		kCmb176:=flag_I|flag_1	; ゅ
		resultOfKCmb176=xyu
		kCmb177:=flag_I|flag_2	; びゃ
		resultOfKCmb177=bya
		kCmb178:=flag_I|flag_3	; びゅ
		resultOfKCmb178=byu
		kCmb179:=flag_I|flag_4	; びょ
		resultOfKCmb179=byo
		kCmb180:=flag_O|flag_1	; ょ
		resultOfKCmb180=xyo
		kCmb181:=flag_O|flag_2	; ぴゃ
		resultOfKCmb181=pya
		kCmb182:=flag_O|flag_3	; ぴゅ
		resultOfKCmb182=pyu
		kCmb183:=flag_O|flag_4	; ぴょ
		resultOfKCmb183=pyo
		kCmb184:=flag_D|flag_7	; 、
		resultOfKCmb184=`,
		kCmb185:=flag_D|flag_8	; 「
		resultOfKCmb185=[
		kCmb186:=flag_D|flag_9	; 」
		resultOfKCmb186=]
		kCmb187:=flag_D|flag_0	; ；
		resultOfKCmb187=`;
		kCmb188:=flag_D|flag_Hiphen	; @
		resultOfKCmb188=@
		kCmb189:=flag_S|flag_7	; 。
		resultOfKCmb189=.
		kCmb190:=flag_S|flag_8	; （
		resultOfKCmb190=+8
		kCmb191:=flag_S|flag_9	; ）
		resultOfKCmb191=+9
		kCmb192:=flag_S|flag_0	; ：
		resultOfKCmb192=`:
		kCmb193:=flag_S|flag_Hiphen	; ＊
		resultOfKCmb193=+`:
		kCmb194:=flag_F|flag_V	; ！
		resultOfKCmb194=+1
		kCmb195:=flag_F|flag_B	; ！
		resultOfKCmb195=+1
		kCmb196:=flag_N|flag_J	; ？
		resultOfKCmb196=?
		kCmb197:=flag_R|flag_F	; ・
		resultOfKCmb197=/
		kCmb198:=flag_SColon|flag_RBracket	; →
		resultOfKCmb198=→{Enter}
		kCmb199:=flag_L|flag_RBracket	; ←
		resultOfKCmb199=←{Enter}
		kCmb200:=flag_P|flag_RBracket	; ↑
		resultOfKCmb200=↑{Enter}
		kCmb201:=flag_Dot|flag_RBracket	; ↓
		resultOfKCmb201=↓{Enter}
		kCmb202:=flag_Slash|flag_RBracket	; ↓
		resultOfKCmb202=⇒{Enter}
	}else{
		; かな入力時の定義
		; 以下でシングルストロークで send する文字列を定義します
		singleStroke_Q=|	;ー
		singleStroke_W=i	;に
		singleStroke_E=f	;は
		singleStroke_R=+,	;,
		singleStroke_T=a	;ち
		singleStroke_Y=h@	;ぐ
		singleStroke_U=f@	;ば
		singleStroke_I=b	;こ
		singleStroke_O=t@	;が
		singleStroke_P=v	;ひ
		singleStroke_AT=:@	;げ
		singleStroke_A=k	;の
		singleStroke_S=s	;と
		singleStroke_D=t	;か
		singleStroke_F=y	;ん
		singleStroke_G=Z	;っ
		singleStroke_H=h	;く
		singleStroke_J=4	;う
		singleStroke_K=e	;い
		singleStroke_L=d	;し
		singleStroke_SColon=u	;な
		singleStroke_Z=r	;す
		singleStroke_X=j	;ま
		singleStroke_C=g	;き
		singleStroke_V=.	;る
		singleStroke_B=z	;つ
		singleStroke_N=w	;て
		singleStroke_M=q	;た
		singleStroke_Comma=w@	;で
		singleStroke_Dot=+.	;。
		singleStroke_Slash=2@	;ぶ
		singleStroke_1={Numpad1}	;１
		singleStroke_2={Numpad2}	;２
		singleStroke_3={Numpad3}	;３
		singleStroke_4={Numpad4}	;４
		singleStroke_5={Numpad5}	;５
		singleStroke_6={Numpad6}	;６
		singleStroke_7={Numpad7}	;７
		singleStroke_8={Numpad8}	;８
		singleStroke_9={Numpad9}	;９
		singleStroke_0={Numpad0}	;０
		singleStroke_Hiphen=-	;ー
		singleStroke_RBracket=]
		singleStroke_Colon={BackSpace}

		; 同時打鍵の定義
		; kCmb1:=flag_F|flag_J	; を
		; resultOfKCmb1=+0
		kCmb2:=flag_K|flag_Q	; ふぁ
		resultOfKCmb2=2+3
		kCmb3:=flag_K|flag_W	; ご
		resultOfKCmb3=b@
		kCmb4:=flag_K|flag_E	; ふ
		resultOfKCmb4=2
		kCmb5:=flag_K|flag_R	; ふぃ
		resultOfKCmb5=2E
		kCmb6:=flag_K|flag_T	; ふぇ
		resultOfKCmb6=2+5
		kCmb7:=flag_K|flag_A	; ほ
		resultOfKCmb7=-
		kCmb8:=flag_K|flag_S	; じ
		resultOfKCmb8=d@
		kCmb9:=flag_K|flag_D	; れ
		resultOfKCmb9=;
		kCmb10:=flag_K|flag_F	; も
		resultOfKCmb10=m
		kCmb11:=flag_K|flag_G	; ゆ
		resultOfKCmb11=8
		kCmb12:=flag_K|flag_Z	; づ
		resultOfKCmb12=z@
		kCmb13:=flag_K|flag_C	; ぼ
		resultOfKCmb13=-@
		kCmb14:=flag_K|flag_V	; む
		resultOfKCmb14=]
		kCmb15:=flag_K|flag_B	; ふぉ
		resultOfKCmb15=2+6
		kCmb16:=flag_D|flag_Y	; うぃ
		resultOfKCmb16=4E
		kCmb17:=flag_D|flag_U	; ぱ
		resultOfKCmb17=f[
		kCmb18:=flag_D|flag_I	; よ
		resultOfKCmb18=9
		kCmb19:=flag_D|flag_O	; み
		resultOfKCmb19=n
		kCmb20:=flag_D|flag_P	; うぇ
		resultOfKCmb20=4+5
		kCmb21:=flag_D|flag_H	; へ
		resultOfKCmb21=~
		kCmb22:=flag_D|flag_J	; あ
		resultOfKCmb22=3
		kCmb23:=flag_D|flag_SColon	; え
		resultOfKCmb23=5
		kCmb24:=flag_D|flag_N	; せ
		resultOfKCmb24=p
		kCmb25:=flag_D|flag_M	; ね
		resultOfKCmb25=,
		kCmb26:=flag_D|flag_Comma	; べ
		resultOfKCmb26=~@
		kCmb27:=flag_D|flag_Dot	; ぷ
		resultOfKCmb27=2[
		kCmb28:=flag_D|flag_Slash	; ヴ
		resultOfKCmb28=4@
		kCmb29:=flag_L|flag_W	; め
		resultOfKCmb29=/
		kCmb30:=flag_L|flag_E	; け
		resultOfKCmb30=*
		kCmb31:=flag_L|flag_R	; てぃ
		resultOfKCmb31=wE
		kCmb32:=flag_L|flag_T	; でぃ
		resultOfKCmb32=w@E
		kCmb33:=flag_L|flag_A	; を
		resultOfKCmb33=+0
		kCmb34:=flag_L|flag_S	; さ
		resultOfKCmb34=x
		kCmb35:=flag_L|flag_D	; お
		resultOfKCmb35=6
		kCmb36:=flag_L|flag_F	; り
		resultOfKCmb36=l
		kCmb37:=flag_L|flag_G	; ず
		resultOfKCmb37=r@
		kCmb38:=flag_L|flag_Z	; ぜ
		resultOfKCmb38=p@
		kCmb39:=flag_L|flag_X	; ざ
		resultOfKCmb39=x@
		kCmb40:=flag_L|flag_C	; ぎ
		resultOfKCmb40=g@
		kCmb41:=flag_L|flag_V	; ろ
		resultOfKCmb41=_
		kCmb42:=flag_L|flag_B	; ぬ
		resultOfKCmb42=1
		kCmb43:=flag_S|flag_U	; ぺ
		resultOfKCmb43=~[
		kCmb44:=flag_S|flag_I	; ど
		resultOfKCmb44=s@
		kCmb45:=flag_S|flag_O	; や
		resultOfKCmb45=7
		kCmb46:=flag_S|flag_H	; び
		resultOfKCmb46=v@
		kCmb47:=flag_S|flag_J	; ら
		resultOfKCmb47=o
		kCmb48:=flag_S|flag_SColon	; そ
		resultOfKCmb48=c
		kCmb49:=flag_S|flag_N	; わ
		resultOfKCmb49=0
		kCmb50:=flag_S|flag_M	; だ
		resultOfKCmb50=q@
		kCmb51:=flag_S|flag_Comma	; ぴ
		resultOfKCmb51=v[
		kCmb52:=flag_S|flag_Slash	; ちぇ
		resultOfKCmb52=a+5
		kCmb53:=flag_I|flag_R	; きゅ
		resultOfKCmb53=g+8
		kCmb54:=flag_I|flag_F	; きょ
		resultOfKCmb54=g+9
		kCmb55:=flag_I|flag_V	; きゃ
		resultOfKCmb55=g+7
		kCmb56:=flag_I|flag_T	; ちゅ
		resultOfKCmb56=a+8
		kCmb57:=flag_I|flag_G	; ちょ
		resultOfKCmb57=a+9
		kCmb58:=flag_I|flag_B	; ちゃ
		resultOfKCmb58=a+7
		kCmb59:=flag_I|flag_A	; ひょ
		resultOfKCmb59=v+9
		kCmb60:=flag_I|flag_Z	; ひゃ
		resultOfKCmb60=v+7
		kCmb61:=flag_I|flag_X	; くぇ
		resultOfKCmb61=h+5
		kCmb62:=flag_I|flag_C	; しゃ
		resultOfKCmb62=d+7
		kCmb63:=flag_I|flag_Q	; ひゅ
		resultOfKCmb63=v+8
		kCmb64:=flag_I|flag_W	; しゅ
		resultOfKCmb64=d+8
		kCmb65:=flag_I|flag_E	; しょ
		resultOfKCmb65=d+9
		kCmb76:=flag_O|flag_R	; ぎゅ
		resultOfKCmb76=g@+8
		kCmb77:=flag_O|flag_F	; ぎょ
		resultOfKCmb77=g@+9
		kCmb78:=flag_O|flag_V	; ぎゃ
		resultOfKCmb78=g@+7
		kCmb79:=flag_O|flag_T	; にゅ
		resultOfKCmb79=i+8
		kCmb80:=flag_O|flag_G	; にょ
		resultOfKCmb80=i+9
		kCmb81:=flag_O|flag_B	; にゃ
		resultOfKCmb81=i+7
		kCmb82:=flag_O|flag_A	; りょ
		resultOfKCmb82=l+9
		kCmb83:=flag_O|flag_Z	; りゃ
		resultOfKCmb83=l+7
		kCmb84:=flag_O|flag_X	; ぐぇ
		resultOfKCmb84=h@+5
		kCmb85:=flag_O|flag_C	; じゃ
		resultOfKCmb85=d@+7
		kCmb86:=flag_O|flag_Q	; りゅ
		resultOfKCmb86=l+8
		kCmb87:=flag_O|flag_W	; じゅ
		resultOfKCmb87=d@+8
		kCmb88:=flag_O|flag_E	; じょ
		resultOfKCmb88=d@+9
		kCmb141:=flag_W|flag_E	; (
		resultOfKCmb141=(
		kCmb142:=flag_E|flag_R	; !
		resultOfKCmb142={!}
		kCmb143:=flag_E|flag_F	; ~
		resultOfKCmb143=,~
		kCmb144:=flag_R|flag_G	; ・
		resultOfKCmb144=/
		kCmb145:=flag_S|flag_D	; [
		resultOfKCmb145=[
		kCmb147:=flag_F|flag_G	; 「」
		resultOfKCmb147=+[+]{Enter}{Left}
		kCmb148:=flag_D|flag_V	; @
		resultOfKCmb148=@
		kCmb149:=flag_X|flag_C	; {
		resultOfKCmb149={{}
		kCmb150:=flag_C|flag_V	; ,
		resultOfKCmb150=`,
		kCmb151:=flag_U|flag_I	; ?
		resultOfKCmb151=?
		kCmb152:=flag_I|flag_O	; )
		resultOfKCmb152=)
		kCmb153:=flag_U|flag_H	; ／
		resultOfKCmb153=【】{Enter}{Left}
		kCmb155:=flag_H|flag_J	; （）
		resultOfKCmb155=+8+9{F9}{Enter}{Left}
		kCmb157:=flag_K|flag_L	; ]
		resultOfKCmb157=]
		kCmb158:=flag_K|flag_N	; \
		resultOfKCmb158=\
		kCmb159:=flag_M|flag_Comma	; ,
		resultOfKCmb159=`,
		kCmb160:=flag_Comma|flag_Dot	; ｝
		resultOfKCmb160={}}
		kCmb161:=flag_K|flag_X	; ぞ
		resultOfKCmb161=c@
		kCmb162:=flag_L|flag_Q	; ぢ
		resultOfKCmb162=a@
		kCmb163:=flag_S|flag_Y	; しぇ
		resultOfKCmb163=d+5
		kCmb164:=flag_S|flag_Dot	; ぽ
		resultOfKCmb164=-[
		kCmb165:=flag_S|flag_P	; じぇ
		resultOfKCmb165=d@+5
		kCmb166:=flag_K|flag_1	; ぁ
		resultOfKCmb166=+3
		kCmb167:=flag_K|flag_2	; ぃ
		resultOfKCmb167=E
		kCmb168:=flag_K|flag_3	; ぅ
		resultOfKCmb168=+4
		kCmb169:=flag_K|flag_4	; ぇ
		resultOfKCmb169=+5
		kCmb170:=flag_K|flag_5	; ぉ
		resultOfKCmb170=+6
		kCmb171:=flag_L|flag_1	; ゃ
		resultOfKCmb171=+7
		kCmb172:=flag_L|flag_2	; みゃ
		resultOfKCmb172=n+7
		kCmb173:=flag_L|flag_3	; みゅ
		resultOfKCmb173=n+8
		kCmb174:=flag_L|flag_4	; みょ
		resultOfKCmb174=n+9
		kCmb175:=flag_L|flag_5	; ゎ
		resultOfKCmb175=ゎ
		kCmb176:=flag_I|flag_1	; ゅ
		resultOfKCmb176=+8
		kCmb177:=flag_I|flag_2	; びゃ
		resultOfKCmb177=v@+7
		kCmb178:=flag_I|flag_3	; びゅ
		resultOfKCmb178=v@+8
		kCmb179:=flag_I|flag_4	; びょ
		resultOfKCmb179=v@+9
		kCmb180:=flag_O|flag_1	; ょ
		resultOfKCmb180=+9
		kCmb181:=flag_O|flag_2	; ぴゃ
		resultOfKCmb181=v[+7
		kCmb182:=flag_O|flag_3	; ぴゅ
		resultOfKCmb182=v[+8
		kCmb183:=flag_O|flag_4	; ぴょ
		resultOfKCmb183=v[+9
		kCmb184:=flag_D|flag_7	; 、
		resultOfKCmb184=`,
		kCmb185:=flag_D|flag_8	; 「
		resultOfKCmb185=[
		kCmb186:=flag_D|flag_9	; 」
		resultOfKCmb186=]
		kCmb187:=flag_D|flag_0	; ；
		resultOfKCmb187=`;
		kCmb188:=flag_D|flag_Hiphen	; @
		resultOfKCmb188=@
		kCmb189:=flag_S|flag_7	; 。
		resultOfKCmb189=+.
		kCmb190:=flag_S|flag_8	; （
		resultOfKCmb190=（
		kCmb191:=flag_S|flag_9	; ）
		resultOfKCmb191=）
		kCmb192:=flag_S|flag_0	; ：
		resultOfKCmb192=`:{F9}
		kCmb193:=flag_S|flag_Hiphen	; ＊
		resultOfKCmb193=+`:{F9}
		kCmb194:=flag_F|flag_V	; ！
		resultOfKCmb194=！
		kCmb195:=flag_F|flag_B	; ！
		resultOfKCmb195=！
		kCmb196:=flag_N|flag_J	; ？
		resultOfKCmb196=？
		kCmb197:=flag_R|flag_F	; ・
		resultOfKCmb197=・{Enter}
		kCmb198:=flag_SColon|flag_RBracket	; →
		resultOfKCmb198=→{Enter}
		kCmb199:=flag_L|flag_RBracket	; ←
		resultOfKCmb199=←{Enter}
		kCmb200:=flag_P|flag_RBracket	; ↑
		resultOfKCmb200=↑{Enter}
		kCmb201:=flag_Dot|flag_RBracket	; ↓
		resultOfKCmb201=↓{Enter}
		kCmb202:=flag_Slash|flag_RBracket	; ↓
		resultOfKCmb202=⇒{Enter}
	}
}




;================
; 同時打鍵の判定
;================

;=================================
; キーを押し込んでも即座には入力されません
; 入力を確定するタイミングは次の２つです
; 
; 1. 次のキーが押されたとき (onKeyDown)
; 2. ある程度の時間が経過したとき (確定タイマー)
; 
; 確定タイマーはキーが押されたときにセット/リセットされ、
; 入力が確定したときに解除されます
; 確定タイマーはonKeyUp ルーチンを呼びます
;=================================

outputChar(string){
	send, %string%
}

onKeyUp:
	if(bufKey)
	{
		outputChar(singleStroke%bufKey%)
		bufKey:=0
	}
	setTimer, onKeyUp, Off
Return

onKeyDown(keyName){
	global gDownKeyName

    if( IME_GET() || MenuTypingValue)
	{
		gDownKeyName:=keyName
		GoSub onOnKeyDown
		return
	}
	send,% defaultKey%keyName%
}

onOnKeyDown:
	inputTime:=A_TickCount

	if(bufKey){
		; GapTime が許容値内であるか
		if( inputTime-bufTime <= MaximalGT )
		{
			currentKeyPattern:=flag%gDownKeyName%|flag%bufKey%
			Loop, %NumberOfKCmb%
			{
				; 押下中の組み合わせが定義されているか
				if( KCmb%A_Index% == currentKeyPattern)
				{
					; 同時打鍵を出力、バッファとタイマーをクリア
					outputChar( resultOfKCmb%A_Index%)
					bufKey:=0
					setTimer, onKeyUp, Off
					Return
				}
			}
		}
		; 同時打鍵でなかったらバッファを確定
		outputChar( singleStroke%bufKey%)
	}
	; バッファ更新、タイマー設定
	bufTime:=inputTime
	bufKey:=gDownKeyName
	setTimer, onKeyUp, %SingleKeyWait%

	gDownKeyName:=0
Return


; 以下ホットキー定義
#UseHook On

^Esc::
	Suspend,Toggle
	if(A_IsSuspended = 1) 
	{
		Menu, Tray, Icon, %A_ScriptDir%\ShinGeta_off.ico , ,1
	}
	else
	{
		Menu, Tray, Icon, %A_ScriptDir%\ShinGeta_on.ico , ,1
	}
Return
^F12::
	Menu_Typing()
Return

q::onKeyDown("_Q")
w::onKeyDown("_W")
e::onKeyDown("_E")
r::onKeyDown("_R")
t::onKeyDown("_T")
y::onKeyDown("_Y")
u::onKeyDown("_U")
i::onKeyDown("_I")
o::onKeyDown("_O")
p::onKeyDown("_P")
@::onKeyDown("_AT")
a::onKeyDown("_A")
s::onKeyDown("_S")
d::onKeyDown("_D")
f::onKeyDown("_F")
g::onKeyDown("_G")
h::onKeyDown("_H")
j::onKeyDown("_J")
k::onKeyDown("_K")
l::onKeyDown("_L")
z::onKeyDown("_Z")
x::onKeyDown("_X")
`;::onKeyDown("_SColon")
c::onKeyDown("_C")
v::onKeyDown("_V")
b::onKeyDown("_B")
n::onKeyDown("_N")
m::onKeyDown("_M")
.::onKeyDown("_Dot")
/::onKeyDown("_Slash")
sc033::onKeyDown("_Comma")
1::onKeyDown("_1")
2::onKeyDown("_2")
3::onKeyDown("_3")
4::onKeyDown("_4")
5::onKeyDown("_5")
6::onKeyDown("_6")
7::onKeyDown("_7")
8::onKeyDown("_8")
9::onKeyDown("_9")
0::onKeyDown("_0")
-::onKeyDown("_Hiphen")
[::onKeyDown("_LBracket")
]::onKeyDown("_RBracket")
:::onKeyDown("_Colon")
~::onKeyDown("_Hat")
|::onKeyDown("_Pipe")

#UseHook Off



;ヘルパー機能
+^h::
	ime_mode := IME_GET()
	IME_SET(0)
	curTypingMode := MenuTypingValue

	MenuTypingValue = 0
	InputBox, UserInput, 補助, 入力方法を調べたい文字のローマ字を入力, , 300, 130
	MenuTypingValue := curTypingMode
	IME_SET(ime_mode)
	If (ErrorLevel = 0)
	{
		; MsgBox, You entered "%UserInput%"
		If (UserInput = "a")
		{
			MsgBox, D + J
		}
		Else If  (UserInput = "i")
		{
			MsgBox, K
		}
		Else If  (UserInput = "u")
		{
			MsgBox, J
		}
		Else If  (UserInput = "e")
		{
			MsgBox, D + `;
		}
		Else If  (UserInput = "o")
		{
			MsgBox, D + L
		}
		Else If  (UserInput = "ka")
		{
			MsgBox, D
		}
		Else If  (UserInput = "ki")
		{
			MsgBox, C
		}
		Else If  (UserInput = "ku")
		{
			MsgBox, H
		}
		Else If  (UserInput = "ke")
		{
			MsgBox, E + L
		}
		Else If  (UserInput = "ko")
		{
			MsgBox, I
		}
		Else If  (UserInput = "sa")
		{
			MsgBox, S + L
		}
		Else If  (UserInput = "si" || UserInput = "shi")
		{
			MsgBox, L
		}
		Else If  (UserInput = "su")
		{
			MsgBox, Z
		}
		Else If  (UserInput = "se")
		{
			MsgBox, D + N
		}
		Else If  (UserInput = "so")
		{
			MsgBox, S + `;
		}
		Else If  (UserInput = "ta")
		{
			MsgBox, M
		}
		Else If  (UserInput = "ti" || UserInput = "chi")
		{
			MsgBox, T
		}
		Else If  (UserInput = "tu" || UserInput = "tsu")
		{
			MsgBox, B
		}
		Else If  (UserInput = "te")
		{
			MsgBox, N
		}
		Else If  (UserInput = "to")
		{
			MsgBox, S
		}
		Else If  (UserInput = "na")
		{
			MsgBox, `;
		}
		Else If  (UserInput = "ni")
		{
			MsgBox, W
		}
		Else If  (UserInput = "nu")
		{
			MsgBox, B + L
		}
		Else If  (UserInput = "ne")
		{
			MsgBox, D + M
		}
		Else If  (UserInput = "no")
		{
			MsgBox, A
		}
		Else If  (UserInput = "ha")
		{
			MsgBox, E
		}
		Else If  (UserInput = "hi")
		{
			MsgBox, P
		}
		Else If  (UserInput = "hu" || UserInput = "fu")
		{
			MsgBox, E + K
		}
		Else If  (UserInput = "he")
		{
			MsgBox, D + H
		}
		Else If  (UserInput = "ho")
		{
			MsgBox, A + K
		}
		Else If  (UserInput = "ma")
		{
			MsgBox, X
		}
		Else If  (UserInput = "mi")
		{
			MsgBox, D + O
		}
		Else If  (UserInput = "mu")
		{
			MsgBox, V + K
		}
		Else If  (UserInput = "me")
		{
			MsgBox, W + L
		}
		Else If  (UserInput = "mo")
		{
			MsgBox, F + K
		}
		Else If  (UserInput = "ya")
		{
			MsgBox, S + O
		}
		Else If  (UserInput = "yu")
		{
			MsgBox, G + K
		}
		Else If  (UserInput = "yo")
		{
			MsgBox, D + I
		}
		Else If  (UserInput = "ra")
		{
			MsgBox, S + J
		}
		Else If  (UserInput = "ri")
		{
			MsgBox, F + L
		}
		Else If  (UserInput = "ru")
		{
			MsgBox, V
		}
		Else If  (UserInput = "re")
		{
			MsgBox, D + K
		}
		Else If  (UserInput = "ro")
		{
			MsgBox, V + L
		}
		Else If  (UserInput = "wa")
		{
			MsgBox, S + N
		}
		Else If  (UserInput = "wo")
		{
			MsgBox, A + L
		}
		Else If  (UserInput = "n" || UserInput = "nn")
		{
			MsgBox, F
		}
		Else If  (UserInput = "ga")
		{
			MsgBox, O
		}
		Else If  (UserInput = "gi")
		{
			MsgBox, C + L
		}
		Else If  (UserInput = "gu")
		{
			MsgBox, Y
		}
		Else If  (UserInput = "ge")
		{
			MsgBox, @
		}
		Else If  (UserInput = "go")
		{
			MsgBox, W + K
		}
		Else If  (UserInput = "za")
		{
			MsgBox, X + L
		}
		Else If  (UserInput = "zi" || UserInput = "ji")
		{
			MsgBox, S + K
		}
		Else If  (UserInput = "zu")
		{
			MsgBox, G + L
		}
		Else If  (UserInput = "ze")
		{
			MsgBox, Z + L
		}
		Else If  (UserInput = "zo")
		{
			MsgBox, X + K
		}
		Else If  (UserInput = "da")
		{
			MsgBox, S + M
		}
		Else If  (UserInput = "di")
		{
			MsgBox, Q + L
		}
		Else If  (UserInput = "du")
		{
			MsgBox, Z + K
		}
		Else If  (UserInput = "de")
		{
			MsgBox, `,
		}
		Else If  (UserInput = "do")
		{
			MsgBox, S + I
		}
		Else If  (UserInput = "ba")
		{
			MsgBox, U
		}
		Else If  (UserInput = "bi")
		{
			MsgBox, S + H
		}
		Else If  (UserInput = "bu")
		{
			MsgBox, /
		}
		Else If  (UserInput = "be")
		{
			MsgBox, D + `,
		}
		Else If  (UserInput = "bo")
		{
			MsgBox, C + K
		}
		Else If  (UserInput = "pa")
		{
			MsgBox, D + U
		}
		Else If  (UserInput = "pi")
		{
			MsgBox, S + `,
		}
		Else If  (UserInput = "pu")
		{
			MsgBox, D + .
		}
		Else If  (UserInput = "pe")
		{
			MsgBox, S + U
		}
		Else If  (UserInput = "po")
		{
			MsgBox, S + .
		}
		Else If (UserInput = "fa")
		{
			MsgBox, Q + K
		}
		Else If (UserInput = "fi")
		{
			MsgBox, R + K
		}
		Else If (UserInput = "fe")
		{
			MsgBox, T + K
		}
		Else If (UserInput = "fo")
		{
			MsgBox, B + K
		}
		Else If (UserInput = "wi")
		{
			MsgBox, D + Y
		}
		Else If (UserInput = "we")
		{
			MsgBox, D + P
		}
		Else If (UserInput = "vu")
		{
			MsgBox, D + /
		}
		Else If (UserInput = "texi" || UserInput = "thi")
		{
			MsgBox, R + L
		}
		Else If (UserInput = "dexi" || UserInput = "dhi")
		{
			MsgBox, T + L
		}
		Else If (UserInput = "che" || UserInput = "tye")
		{
			MsgBox, S + /
		}
		Else If (UserInput = "kyu")
		{
			MsgBox, R + I
		}
		Else If (UserInput = "kyo")
		{
			MsgBox, F + I
		}
		Else If (UserInput = "kya")
		{
			MsgBox, V + I
		}
		Else If (UserInput = "cyu" || UserInput = "tyu" || UserInput = "chu")
		{
			MsgBox, T + I
		}
		Else If (UserInput = "cyo" || UserInput = "tyo" || UserInput = "cho")
		{
			MsgBox, G + I
		}
		Else If (UserInput = "cya" || UserInput = "tya" || UserInput = "cha")
		{
			MsgBox, B + I
		}
		Else If (UserInput = "hyo")
		{
			MsgBox, A + I
		}
		Else If (UserInput = "hya")
		{
			MsgBox, Z + I
		}
		Else If (UserInput = "qe")
		{
			MsgBox, X + I
		}
		Else If (UserInput = "sha" || UserInput = "sya")
		{
			MsgBox, C + I
		}
		Else If (UserInput = "hyu")
		{
			MsgBox, Q + I
		}
		Else If (UserInput = "shu")
		{
			MsgBox, W + I
		}
		Else If (UserInput = "syo" || UserInput = "sho")
		{
			MsgBox, E + I
		}
		; Else If (UserInput = "hya")
		; {
		; 	MsgBox, E + Y
		; }
		; Else If (UserInput = "hyo")
		; {
		; 	MsgBox, E + H
		; }
		; Else If (UserInput = "hyu")
		; {
		; 	MsgBox, E + N
		; }
		; Else If (UserInput = "kya")
		; {
		; 	MsgBox, E + U
		; }
		; Else If (UserInput = "kyo")
		; {
		; 	MsgBox, E + J
		; }
		; Else If (UserInput = "kyu")
		; {
		; 	MsgBox, E + M
		; }
		; Else If (UserInput = "hye")
		; {
		; 	MsgBox, 新下駄にはなし。ひ＋ぇ
		; }
		; Else If (UserInput = "tha")
		; {
		; 	MsgBox, 新下駄にはなし。て＋ゃ
		; }
		; Else If (UserInput = "thu")
		; {
		; 	MsgBox, 新下駄にはなし。て＋ゅ
		; }
		; Else If (UserInput = "tho")
		; {
		; 	MsgBox, 新下駄にはなし。て＋ょ
		; }
		Else If (UserInput = "gyu")
		{
			MsgBox, R + O
		}
		Else If (UserInput = "gyo")
		{
			MsgBox, F + O
		}
		Else If (UserInput = "gya")
		{
			MsgBox, V + O
		}
		Else If (UserInput = "nyu")
		{
			MsgBox, T + O
		}
		Else If (UserInput = "nyo")
		{
			MsgBox, G + O
		}
		Else If (UserInput = "nya")
		{
			MsgBox, B + O
		}
		Else If (UserInput = "ryo")
		{
			MsgBox, A + O
		}
		Else If (UserInput = "rya")
		{
			MsgBox, Z + O
		}
		Else If (UserInput = "gwe")
		{
			MsgBox, X + O
		}
		Else If (UserInput = "ja")
		{
			MsgBox, C + O
		}
		Else If (UserInput = "ryu")
		{
			MsgBox, Q + O
		}
		Else If (UserInput = "ju")
		{
			MsgBox, W + O
		}
		Else If (UserInput = "jo")
		{
			MsgBox, E + O
		}
		; Else If (UserInput = "bya")
		; {
		; 	MsgBox, W + Y
		; }
		; Else If (UserInput = "byo")
		; {
		; 	MsgBox, W + H
		; }
		; Else If (UserInput = "byu")
		; {
		; 	MsgBox, W + N
		; }
		; Else If (UserInput = "gya")
		; {
		; 	MsgBox, W + U
		; }
		; Else If (UserInput = "gyo")
		; {
		; 	MsgBox, W + J
		; }
		; Else If (UserInput = "gyu")
		; {
		; 	MsgBox, W + M
		; }
		; Else If (UserInput = "bye")
		; {
		; 	MsgBox, W + `;
		; }
		; Else If (UserInput = "dha")
		; {
		; 	MsgBox, W + `,
		; }
		; Else If (UserInput = "dhu")
		; {
		; 	MsgBox, W + .
		; }
		; Else If (UserInput = "dho")
		; {
		; 	MsgBox, W + /
		; }
		; Else If (UserInput = "rya")
		; {
		; 	MsgBox, R + `;
		; }
		; Else If (UserInput = "ryo")
		; {
		; 	MsgBox, F + `;
		; }
		; Else If (UserInput = "ryu")
		; {
		; 	MsgBox, V + `;
		; }
		; Else If (UserInput = "mya")
		; {
		; 	MsgBox, T + `;
		; }
		; Else If (UserInput = "myo")
		; {
		; 	MsgBox, G + `;
		; }
		; Else If (UserInput = "myu")
		; {
		; 	MsgBox, B + `;
		; }
		; Else If (UserInput = "tsa")
		; {
		; 	MsgBox, A + `;
		; }
		; Else If (UserInput = "tsi")
		; {
		; 	MsgBox, Z + `;
		; }
		; Else If (UserInput = "tse")
		; {
		; 	MsgBox, X + `;
		; }
		; Else If (UserInput = "tso")
		; {
		; 	MsgBox, C + `;
		; }
		; Else If (UserInput = "rye")
		; {
		; 	MsgBox, Q + `;
		; }
		; Else If (UserInput = "pya")
		; {
		; 	MsgBox, A + Y
		; }
		; Else If (UserInput = "pyo")
		; {
		; 	MsgBox, A + H
		; }
		; Else If (UserInput = "pyu")
		; {
		; 	MsgBox, A + N
		; }
		; Else If (UserInput = "nya")
		; {
		; 	MsgBox, A + U
		; }
		; Else If (UserInput = "nyo")
		; {
		; 	MsgBox, A + J
		; }
		; Else If (UserInput = "nyu")
		; {
		; 	MsgBox, A + M
		; }
		; Else If (UserInput = "ye")
		; {
		; 	MsgBox, A + `,
		; }
		; Else If (UserInput = "nye")
		; {
		; 	MsgBox, A + .
		; }
		; Else If (UserInput = "mye")
		; {
		; 	MsgBox, A + /
		; }
		; Else If (UserInput = "pye")
		; {
		; 	MsgBox, A + P
		; }
		; Else If (UserInput = "sye")
		; {
		; 	MsgBox, R + J
		; }
		; Else If (UserInput = "je")
		; {
		; 	MsgBox, T + J
		; }
		; Else If (UserInput = "thi")
		; {
		; 	MsgBox, G + J
		; }
		; Else If (UserInput = "fa")
		; {
		; 	MsgBox, V + J
		; }
		; Else If (UserInput = "fi")
		; {
		; 	MsgBox, B + J
		; }
		; Else If (UserInput = "wi")
		; {
		; 	MsgBox, Z + J
		; }
		; Else If (UserInput = "we")
		; {
		; 	MsgBox, X + J
		; }
		; Else If (UserInput = "who")
		; {
		; 	MsgBox, C + J
		; }
		; Else If (UserInput = "dile")
		; {
		; 	MsgBox, F + Y
		; }
		; Else If (UserInput = "che")
		; {
		; 	MsgBox, F + U
		; }
		; Else If (UserInput = "dhi")
		; {
		; 	MsgBox, F + H
		; }
		; Else If (UserInput = "fe")
		; {
		; 	MsgBox, F + N
		; }
		; Else If (UserInput = "fo")
		; {
		; 	MsgBox, F + M
		; }
		; Else If (UserInput = "twu")
		; {
		; 	MsgBox, F + `,
		; }
		; Else If (UserInput = "dwu")
		; {
		; 	MsgBox, F + .
		; }
		; Else If (UserInput = "fyu")
		; {
		; 	MsgBox, F + /
		; }
		; Else If (UserInput = "va")
		; {
		; 	MsgBox, A + @
		; }
		; Else If (UserInput = "vi")
		; {
		; 	MsgBox, S + @
		; }
		; Else If (UserInput = "uxo")
		; {
		; 	MsgBox, D + @
		; }
		; Else If (UserInput = "ve")
		; {
		; 	MsgBox, F + @
		; }
		; Else If (UserInput = "vo")
		; {
		; 	MsgBox, G + @
		; }
		Else If (UserInput = "she")
		{
			MsgBox, S + Y
		}
		Else If (UserInput = "je")
		{
			MsgBox, S + P
		}
		Else If (UserInput = "xa" || UserInput = "la")
		{
			MsgBox, 1 + K
		}
		Else If (UserInput = "xi" || UserInput = "li")
		{
			MsgBox, 2 + K
		}
		Else If (UserInput = "xu" || UserInput = "lu")
		{
			MsgBox, 3 + K
		}
		Else If (UserInput = "xe" || UserInput = "le")
		{
			MsgBox, 4 + K
		}
		Else If (UserInput = "xo" || UserInput = "lo")
		{
			MsgBox, 5 + K
		}
		Else If (UserInput = "xya" || UserInput = "lya")
		{
			MsgBox, 1 + L
		}
		Else If (UserInput = "mya")
		{
			MsgBox, 2 + L
		}
		Else If (UserInput = "myu")
		{
			MsgBox, 3 + L
		}
		Else If (UserInput = "myo")
		{
			MsgBox, 4 + L
		}
		Else If (UserInput = "xwa" || UserInput = "lwa")
		{
			MsgBox, 5 + L
		}
		Else If (UserInput = "xyu" || UserInput = "lyu")
		{
			MsgBox, 1 + I
		}
		Else If (UserInput = "bya")
		{
			MsgBox, 2 + I
		}
		Else If (UserInput = "byu")
		{
			MsgBox, 3 + I
		}
		Else If (UserInput = "byo")
		{
			MsgBox, 4 + I
		}
		Else If (UserInput = "xyo" || UserInput = "lyo")
		{
			MsgBox, 1 + O
		}
		Else If (UserInput = "pya")
		{
			MsgBox, 2 + O
		}
		Else If (UserInput = "pyu")
		{
			MsgBox, 3 + O
		}
		Else If (UserInput = "pyo")
		{
			MsgBox, 4 + O
		}
		Else
		{
			MsgBox, 新下駄にはないか、ローマ字入力が想定外。
		}	
	}
Return