# ソフトウェアについて

【名    称】盤上の隅っこで
【種    別】ゴースト
【制 作 者】タタキノフ
【動作確認】Windows 10 and Wine 5.7以降 / SSP 2.4.72
【配 布 元】https://tatakinov.github.io/
【連 絡 先】tatakinov_at_gmail.com
            https://twitter.com/tatakinov_ukgk


## ゴーストについて

将棋ゴーストです。遊べます。


## ゴースト著作権について

[1.ゴーストダウンロードページに直接リンクされる]
○

[2.ゴーストのネタバレをされる]
○

[3.ゴーストに対し批判的な意見を言われる]
○
作者の髪が薄くなります。

[4.二次創作物の配布をされる(HP素材フリー配布、同人誌販売等)]
[5.原作の設定と大きくかけ離れた二次創作をされる]
[6.18禁二次創作をされる]
○
ただし二次創作物である旨を目につく場所に記載すること。

[7.追加シェル、バルーン等を配布される]
○
- シェルについて
    辞書内ではsurfacesのalias.txtに書かれたaliasを
    利用するようにしているため、masterシェルと同じ番号にしなくても
    aliasさえ一致していれば大丈夫です。
    そのため、シェルのファイル名およびsurfaceIDは
    masterシェルと同じである必要はありません。
    ただし、あくまでsurfaceIDだけなので扇子のanimationIDは
    一致させる必要があります。
- 扇子の文字
    1. 涓滴(けんてき)             藤井猛九段の揮毫。
    2. 百折不撓(ひゃくせつふとう) 木村一基九段の揮毫。
    3. 平安(へいあん)             鈴木大介九段の揮毫。
- 盤や駒の画像について
    追加シェルの場合は駒や盤などの画像を用意するのが大変であれば
    masterのものをコピーしても大丈夫です。

[8.マスターシェル、バルーン等を改変したものを配布される]（7がOKの人のみ）
○

[9.トークをウェブ上に転載]
○

[10.マスターシェルを素材(掲示板のアイコンなど)として使用]
○

[11.ゴーストアーカイブへの直リンク]
○

[12.公開中ゴーストをウェブ上で再配布]
○
でもオリジナルをダウンロードしてほしくもある。

[13.配布終了したゴーストをウェブ上で再配布]
○

[14.中身を改変した上でウェブ上で再配布]（12と13のどちらかがOKの人のみ）
○
ただし、改変している旨を目のつく場所に記載すること。

[15.ゴーストの同人誌収録]
[16.ゴーストの商業誌収録]
要相談。
棋譜利用のガイドラインに沿わない棋譜利用があった場合に
大変なことになるので。


# 棋譜の読み上げ音声について

「VOICEVOX:四国めたん」を利用しています。
ホームページ → https://voicevox.hiroshiba.jp/


## 使用ライブラリなど

以下のライブラリ/ソフトウェアを使用しています。
それぞれのライセンス詳細はLICENSE.txtを参照してください。

Lua           | https://www.lua.org/
sol2          | https://github.com/ThePhD/sol2/
luautf8       | https://github.com/starwing/luautf8/
luaex         | https://github.com/LuaDist/luaex/
Luachild      | https://github.com/pocomane/luachild/
LPeg          | http://www.inf.puc-rio.br/~roberto/lpeg/\
shogi686      | https://github.com/merom686/shogi686_sdt5/
sunfish4      | https://github.com/sunfish-shogi/sunfish4/
luacheck      | https://github.com/mpeterv/luacheck/
argparse      | https://github.com/mpeterv/argparse
luafilesystem | https://github.com/keplerproject/luafilesystem/
lanes         | https://github.com/LuaLanes/lanes
MahjongUtil   | https://github.com/nikolat/MahjongUtil
luasocket     | https://github.com/diegonehab/luasocket
Arasan        | https://www.arasanchess.org/


## 使用フォント

駒や指し手などの文字にM+ BITMAP FONTを使用しています。
ライセンス詳細はshell\master\shogi\LICENSE.txtを参照してください。

メニューのサイドバーにみかちゃんフォントを使用しています。
ライセンス詳細はshell\master\menu\LICENSE.mikachan.txtを参照してください。


## 棋譜について

基本的には作者が将棋を指したり、将棋ソフトで検討()したり、棋書(本)を読んだり、
動画を見たりして得た知識(※)を元に作っています。
出典がある場合は該当するトークが書かれている辞書またはkifファイルに
コメントで記載してあります。
なお、プロの棋譜を用いた部分については
棋譜利用のガイドライン | https://www.shogi.or.jp/kifuguideline/terms.html
を守った範囲で利用しているはずです。
万が一上記のガイドラインを無視した棋譜利用がありましたら
連絡をお願いいたします。

※棋書で詳細に書かれている変化についてはあまり触れないはずです。
相振り飛車を指しこなす本くらいしかまともに読んでいませんが念のため。


## メニューの詰将棋のようなものについて

作者が考えてはいますが、万が一
同一作品が存在していた場合は連絡してくださると助かります。


## 参考にしたあれこれ

- 栞関連

  UKADOC Project
    さくらスクリプトリスト/ http://ssp.shillest.net/ukadoc/manual/list_sakura_script.html
  lua-users wiki          / http://lua-users.org/wiki/
  tkytk                   / https://github.com/kinokon/tkytk
  山茱萸しゃしゃぶ        / リンク切れ


- ゴースト作成

  着せ替えやアニメーションの作り方
                          / http://earlduant.github.io/ukagaka-shell-description/animations.html


- SAORI(process.dll)

  さおり                  / http://www.boreas.dti.ne.jp/~sdn/saori.html
  伺か - SSTPプロトコル   / http://usada.sakura.vg/contents/sstp.html
  伺か - メモリオブジェクト
                          / http://usada.sakura.vg/contents/objects.html


- フォント

  mieki256's diary - BDFフォントをアウトラインフォントにしてみたい
                          / http://blawat2015.no-ip.com/~mieki256/diary/201905281.html


- 棋譜フォーマットやUSIプロトコル

  JSON棋譜フォーマット    / https://github.com/na2hiro/json-kifu-format
  USIプロトコルとは       / http://shogidokoro.starfree.jp/usi.html
  棋譜の表記方法          / https://www.shogi.or.jp/faq/kihuhyouki.html


- 将棋トーク

  将棋盤局面図を作成      / http://sfenreader.appspot.com/ja/create_board.html
  将棋講座(ButaneGorilla) / https://www.nicovideo.jp/mylist/50368976

- デバッグ(luacheck)のコンパイル
  luastatic               / https://github.com/ers35/luastatic

## サプリメントについて

「盤上の隅っこで」には将棋の思考エンジンを導入するためのサプリメントが存在します。
ゴーストをつつくと出てくるメニューから「対局する」を選ぶと
対局メニューが出てきます。
そのメニューから「思考エンジンのインストール」を選択すると導入出来ます。


### 配布元について

https://github.com/Tatakinov/banjou_no_sumikko_de_supplement


### 将棋の思考エンジンについて

#### shogi686_sdt5
atomic_intやsizeof関係のコンパイルエラーが出ていた部分を修正しています。
また、指し手にランダム性を持たせるために、
ソースコードに少し手を加えています。
評価関数は適当に何日か学習させたものを作成しました。

#### sunfish4
32bitでは_BitScanFoward64が無くてコンパイルエラーが出ていたので
ソースコード内に存在する代替関数を使うように修正しています。
評価関数は、作者の将棋倶楽部24と81dojoの棋譜を学習させたものになっています。
また、序盤が弱いので最低限の定跡を入れてあります。

