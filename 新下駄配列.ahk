﻿#Include  %A_ScriptDir%\IME.ahk

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
Menu, Tray, Add, Typing Mode, Menu_Typing
Menu, Tray, Icon, %A_ScriptDir%\ShinGeta_on.ico , ,1

global MenuTypingValue := 0
Menu, Tray, Uncheck, Typing Mode

Menu_Typing(){
  if(MenuTypingValue = 1){
    Menu, Tray, Uncheck, Typing Mode
    MenuTypingValue=0
  }else{
    Menu, Tray, Check, Typing Mode
    MenuTypingValue=1
  }
}

; Maximal Gap Time は同時打鍵判定用の時定数です
; この時間(ms)内に次の入力があった場合は「同時」と見なします
MaximalGT:=70

; Single Key Wait はキーを押してからタイマーで確定するまでの時間です
SingleKeyWait:=MaximalGT

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
singleStroke_7=7	;７
singleStroke_8=8	;８
singleStroke_9=9	;９
singleStroke_0=0	;０
singleStroke_Hiphen=-	;ー
singleStroke_RBracket=]
singleStroke_Colon={BackSpace}

; 以下は IME がローマ字モードじゃないときに出力する文字です

defaultKey_Q=q
defaultKey_W=w
defaultKey_E=e
defaultKey_R=r
defaultKey_T=t
defaultKey_Y=y
defaultKey_U=u
defaultKey_I=i
defaultKey_O=o
defaultKey_P=p
defaultKey_AT=@
defaultKey_A=a
defaultKey_S=s
defaultKey_D=d
defaultKey_F=f
defaultKey_G=g
defaultKey_H=h
defaultKey_J=j
defaultKey_K=k
defaultKey_L=l
defaultKey_SColon=`;
defaultKey_Colon=`:
defaultKey_Z=z
defaultKey_X=x
defaultKey_C=c
defaultKey_V=v
defaultKey_B=b
defaultKey_N=n
defaultKey_M=m
defaultKey_Comma=`,
defaultKey_Dot=.
defaultKey_Slash=/
defaultKey_1=1
defaultKey_2=2
defaultKey_3=3
defaultKey_4=4
defaultKey_5=5
defaultKey_7=7
defaultKey_8=8
defaultKey_9=9
defaultKey_0=0
defaultKey_Hiphen=-
defaultKey_RBracket=]

; 各キーに同時打鍵判定のための識別フラグをわりあてます

flag_Q:=1
flag_W:=1<<1
flag_E:=1<<2
flag_R:=1<<3
flag_T:=1<<4
flag_Y:=1<<5
flag_U:=1<<6
flag_I:=1<<7
flag_O:=1<<8
flag_P:=1<<9
flag_A:=1<<10
flag_S:=1<<11
flag_D:=1<<12
flag_F:=1<<13
flag_G:=1<<14
flag_H:=1<<15
flag_J:=1<<16
flag_K:=1<<17
flag_L:=1<<18
flag_SColon:=1<<19
flag_Z:=1<<20
flag_X:=1<<21
flag_C:=1<<22
flag_V:=1<<23
flag_B:=1<<24
flag_N:=1<<25
flag_M:=1<<26
flag_Comma:=1<<27
flag_Dot:=1<<28
flag_Slash:=1<<30
flag_AT:=1<<31
flag_Colon:=1<<32
flag_Home:=1<<33
flag_End:=1<<34
flag_1:=1<<35
flag_2:=1<<36
flag_3:=1<<37
flag_4:=1<<38
flag_5:=1<<39
flag_7:=1<<40
flag_8:=1<<41
flag_9:=1<<42
flag_0:=1<<43
flag_Hiphen:=1<<45
flag_RBracket:=1<<46
flag_Colon:=1<<47

; 同時打鍵の定義


kCmb1:=flag_F|flag_J	; を
resultOfKCmb1=wo
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
; kCmb66:=flag_E|flag_Y	; ひゃ
; resultOfKCmb66=hya
; kCmb67:=flag_E|flag_H	; ひょ
; resultOfKCmb67=hyo
; kCmb68:=flag_E|flag_N	; ひゅ
; resultOfKCmb68=hyu
; kCmb69:=flag_E|flag_U	; きゃ
; resultOfKCmb69=kya
; kCmb70:=flag_E|flag_J	; きょ
; resultOfKCmb70=kyo
; kCmb71:=flag_E|flag_M	; きゅ
; resultOfKCmb71=kyu
; kCmb72:=flag_E|flag_SColon	; ひぇ
; resultOfKCmb72=hye
; kCmb73:=flag_E|flag_Comma	; てゃ
; resultOfKCmb73=tha
; kCmb74:=flag_E|flag_Dot	; てゅ
; resultOfKCmb74=thu
; kCmb75:=flag_E|flag_Slash	; てょ
; resultOfKCmb75=tho
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
; kCmb89:=flag_W|flag_Y	; びゃ
; resultOfKCmb89=bya
; kCmb90:=flag_W|flag_H	; びょ
; resultOfKCmb90=byo
; kCmb91:=flag_W|flag_N	; びゅ
; resultOfKCmb91=byu
; kCmb92:=flag_W|flag_U	; ぎゃ
; resultOfKCmb92=gya
; kCmb93:=flag_W|flag_J	; ぎょ
; resultOfKCmb93=gyo
; kCmb94:=flag_W|flag_M	; ぎゅ
; resultOfKCmb94=gyu
; kCmb95:=flag_W|flag_SColon	; びぇ
; resultOfKCmb95=bye
; kCmb96:=flag_W|flag_Comma	; でゃ
; resultOfKCmb96=dha
; kCmb97:=flag_W|flag_Dot	; でゅ
; resultOfKCmb97=dhu
; kCmb98:=flag_W|flag_Slash	; でょ
; resultOfKCmb98=dho
; kCmb99:=flag_SColon|flag_R	; りゃ
; resultOfKCmb99=rya
; kCmb100:=flag_SColon|flag_F	; りょ
; resultOfKCmb100=ryo
; kCmb101:=flag_SColon|flag_V	; りゅ
; resultOfKCmb101=ryu
; kCmb102:=flag_SColon|flag_T	; みゃ
; resultOfKCmb102=mya
; kCmb103:=flag_SColon|flag_G	; みょ
; resultOfKCmb103=myo
; kCmb104:=flag_SColon|flag_B	; みゅ
; resultOfKCmb104=myu
; kCmb105:=flag_SColon|flag_A	; つぁ
; resultOfKCmb105=tsa
; kCmb106:=flag_SColon|flag_Z	; つぃ
; resultOfKCmb106=tsi
; kCmb107:=flag_SColon|flag_X	; つぇ
; resultOfKCmb107=tse
; kCmb108:=flag_SColon|flag_C	; つぉ
; resultOfKCmb108=tso
; kCmb109:=flag_SColon|flag_Q	; りぇ
; resultOfKCmb109=rye
; kCmb110:=flag_A|flag_Y	; ぴゃ
; resultOfKCmb110=pya
; kCmb111:=flag_A|flag_H	; ぴょ
; resultOfKCmb111=pyo
; kCmb112:=flag_A|flag_N	; ぴゅ
; resultOfKCmb112=pyu
; kCmb113:=flag_A|flag_U	; にゃ
; resultOfKCmb113=nya
; kCmb114:=flag_A|flag_J	; にょ
; resultOfKCmb114=nyo
; kCmb115:=flag_A|flag_M	; にゅ
; resultOfKCmb115=nyu
; kCmb116:=flag_A|flag_Comma	; いぇ
; resultOfKCmb116=ye
; kCmb117:=flag_A|flag_Dot	; にぇ
; resultOfKCmb117=nye
; kCmb118:=flag_A|flag_Slash	; みぇ
; resultOfKCmb118=mye
; kCmb119:=flag_A|flag_P	; ぴぇ
; resultOfKCmb119=pye
; kCmb120:=flag_J|flag_R	; しぇ
; resultOfKCmb120=sye
; kCmb121:=flag_J|flag_T	; じぇ
; resultOfKCmb121=je
; kCmb122:=flag_J|flag_G	; てぃ
; resultOfKCmb122=thi
; kCmb123:=flag_J|flag_V	; ふぁ
; resultOfKCmb123=fa
; kCmb124:=flag_J|flag_B	; ふぃ
; resultOfKCmb124=fi
; kCmb125:=flag_J|flag_Z	; うぃ
; resultOfKCmb125=wi
; kCmb126:=flag_J|flag_X	; うぇ
; resultOfKCmb126=we
; kCmb127:=flag_J|flag_C	; うぉ
; resultOfKCmb127=who
; kCmb128:=flag_F|flag_Y	; ぢぇ
; resultOfKCmb128=dile
; kCmb129:=flag_F|flag_U	; ちぇ
; resultOfKCmb129=che
; kCmb130:=flag_F|flag_H	; でぃ
; resultOfKCmb130=dhi
; kCmb131:=flag_F|flag_N	; ふぇ
; resultOfKCmb131=fe
; kCmb132:=flag_F|flag_M	; ふぉ
; resultOfKCmb132=fo
; kCmb133:=flag_F|flag_Comma	; とぅ
; resultOfKCmb133=twu
; kCmb134:=flag_F|flag_Dot	; どぅ
; resultOfKCmb134=dwu
; kCmb135:=flag_F|flag_Slash	; ふゅ
; resultOfKCmb135=fyu
; kCmb136:=flag_AT|flag_A	; ヴぁ
; resultOfKCmb136=va
; kCmb137:=flag_AT|flag_S	; ヴぃ
; resultOfKCmb137=vi
; kCmb138:=flag_AT|flag_D	; うぉ
; resultOfKCmb138=uxo
; kCmb139:=flag_AT|flag_F	; ヴぇ
; resultOfKCmb139=ve
; kCmb140:=flag_AT|flag_G	; ヴぉ
; resultOfKCmb140=vo
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
; kCmb146:=flag_D|flag_F	; ,
; resultOfKCmb146=`,
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
; kCmb154:=flag_I|flag_J	; :
; resultOfKCmb154=`:
kCmb155:=flag_H|flag_J	; （）
resultOfKCmb155=+8+9{Enter}{Left}
; kCmb156:=flag_J|flag_K	; .
; resultOfKCmb156=.
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
; resultOfKCmb198=->{Space}{Enter}
resultOfKCmb198=→{Enter}
kCmb199:=flag_L|flag_RBracket	; ←
resultOfKCmb199=←{Enter}
kCmb200:=flag_P|flag_RBracket	; ↑
resultOfKCmb200=↑{Enter}
kCmb201:=flag_Dot|flag_RBracket	; ↓
resultOfKCmb201=↓{Enter}
kCmb202:=flag_Slash|flag_RBracket	; ↓
resultOfKCmb202=⇒{Enter}
; 同時打鍵パターンの総数
NumberOfKCmb:=202

; キーバッファ
; bufKey には _Q のような名前（文字列）が格納されます
; bufTime はキーが押された時刻です

bufKey:=0
bufTime:=0
gDownKeyName:=0


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
7::onKeyDown("_7")
8::onKeyDown("_8")
9::onKeyDown("_9")
0::onKeyDown("_0")
-::onKeyDown("_Hiphen")
]::onKeyDown("_RBracket")
:::onKeyDown("_Colon")

#UseHook Off



;ヘルパー機能
+^h::
	ime_mode := IME_GET()
	IME_SET(0)

	InputBox, UserInput, 補助, 入力方法を調べたい文字のローマ字を入力, , 300, 130
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
		Else If (UserInput = "texi")
		{
			MsgBox, R + L
		}
		Else If (UserInput = "dexi")
		{
			MsgBox, T + L
		}
		Else If (UserInput = "che")
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
		Else If (UserInput = "hya")
		{
			MsgBox, E + Y
		}
		Else If (UserInput = "hyo")
		{
			MsgBox, E + H
		}
		Else If (UserInput = "hyu")
		{
			MsgBox, E + N
		}
		Else If (UserInput = "kya")
		{
			MsgBox, E + U
		}
		Else If (UserInput = "kyo")
		{
			MsgBox, E + J
		}
		Else If (UserInput = "kyu")
		{
			MsgBox, E + M
		}
		Else If (UserInput = "hye")
		{
			MsgBox, E + `;
		}
		Else If (UserInput = "tha")
		{
			MsgBox, E + `,
		}
		Else If (UserInput = "thu")
		{
			MsgBox, E + .
		}
		Else If (UserInput = "tho")
		{
			MsgBox, E + /
		}
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
		Else If (UserInput = "bya")
		{
			MsgBox, W + Y
		}
		Else If (UserInput = "byo")
		{
			MsgBox, W + H
		}
		Else If (UserInput = "byu")
		{
			MsgBox, W + N
		}
		Else If (UserInput = "gya")
		{
			MsgBox, W + U
		}
		Else If (UserInput = "gyo")
		{
			MsgBox, W + J
		}
		Else If (UserInput = "gyu")
		{
			MsgBox, W + M
		}
		Else If (UserInput = "bye")
		{
			MsgBox, W + `;
		}
		Else If (UserInput = "dha")
		{
			MsgBox, W + `,
		}
		Else If (UserInput = "dhu")
		{
			MsgBox, W + .
		}
		Else If (UserInput = "dho")
		{
			MsgBox, W + /
		}
		Else If (UserInput = "rya")
		{
			MsgBox, R + `;
		}
		Else If (UserInput = "ryo")
		{
			MsgBox, F + `;
		}
		Else If (UserInput = "ryu")
		{
			MsgBox, V + `;
		}
		Else If (UserInput = "mya")
		{
			MsgBox, T + `;
		}
		Else If (UserInput = "myo")
		{
			MsgBox, G + `;
		}
		Else If (UserInput = "myu")
		{
			MsgBox, B + `;
		}
		Else If (UserInput = "tsa")
		{
			MsgBox, A + `;
		}
		Else If (UserInput = "tsi")
		{
			MsgBox, Z + `;
		}
		Else If (UserInput = "tse")
		{
			MsgBox, X + `;
		}
		Else If (UserInput = "tso")
		{
			MsgBox, C + `;
		}
		Else If (UserInput = "rye")
		{
			MsgBox, Q + `;
		}
		Else If (UserInput = "pya")
		{
			MsgBox, A + Y
		}
		Else If (UserInput = "pyo")
		{
			MsgBox, A + H
		}
		Else If (UserInput = "pyu")
		{
			MsgBox, A + N
		}
		Else If (UserInput = "nya")
		{
			MsgBox, A + U
		}
		Else If (UserInput = "nyo")
		{
			MsgBox, A + J
		}
		Else If (UserInput = "nyu")
		{
			MsgBox, A + M
		}
		Else If (UserInput = "ye")
		{
			MsgBox, A + `,
		}
		Else If (UserInput = "nye")
		{
			MsgBox, A + .
		}
		Else If (UserInput = "mye")
		{
			MsgBox, A + /
		}
		Else If (UserInput = "pye")
		{
			MsgBox, A + P
		}
		Else If (UserInput = "sye")
		{
			MsgBox, R + J
		}
		Else If (UserInput = "je")
		{
			MsgBox, T + J
		}
		Else If (UserInput = "thi")
		{
			MsgBox, G + J
		}
		Else If (UserInput = "fa")
		{
			MsgBox, V + J
		}
		Else If (UserInput = "fi")
		{
			MsgBox, B + J
		}
		Else If (UserInput = "wi")
		{
			MsgBox, Z + J
		}
		Else If (UserInput = "we")
		{
			MsgBox, X + J
		}
		Else If (UserInput = "who")
		{
			MsgBox, C + J
		}
		Else If (UserInput = "dile")
		{
			MsgBox, F + Y
		}
		Else If (UserInput = "che")
		{
			MsgBox, F + U
		}
		Else If (UserInput = "dhi")
		{
			MsgBox, F + H
		}
		Else If (UserInput = "fe")
		{
			MsgBox, F + N
		}
		Else If (UserInput = "fo")
		{
			MsgBox, F + M
		}
		Else If (UserInput = "twu")
		{
			MsgBox, F + `,
		}
		Else If (UserInput = "dwu")
		{
			MsgBox, F + .
		}
		Else If (UserInput = "fyu")
		{
			MsgBox, F + /
		}
		Else If (UserInput = "va")
		{
			MsgBox, A + @
		}
		Else If (UserInput = "vi")
		{
			MsgBox, S + @
		}
		Else If (UserInput = "uxo")
		{
			MsgBox, D + @
		}
		Else If (UserInput = "ve")
		{
			MsgBox, F + @
		}
		Else If (UserInput = "vo")
		{
			MsgBox, G + @
		}
		Else If (UserInput = "she")
		{
			MsgBox, S + Y
		}
		Else If (UserInput = "je")
		{
			MsgBox, S + P
		}
		Else If (UserInput = "xa")
		{
			MsgBox, 1 + K
		}
		Else If (UserInput = "xi")
		{
			MsgBox, 2 + K
		}
		Else If (UserInput = "xu")
		{
			MsgBox, 3 + K
		}
		Else If (UserInput = "xe")
		{
			MsgBox, 4 + K
		}
		Else If (UserInput = "xo")
		{
			MsgBox, 5 + K
		}
		Else If (UserInput = "xya")
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
		Else If (UserInput = "xwa")
		{
			MsgBox, 5 + L
		}
		Else If (UserInput = "xyu")
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
		Else If (UserInput = "xyo")
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
		
	}
	IME_SET(ime_mode)
Return