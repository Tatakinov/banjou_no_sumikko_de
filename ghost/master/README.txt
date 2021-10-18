# KAGARI/KOTORIについて

KAGARIはluaでなんやかんやする栞です。
KAGARIは処理内容はtkytkとほぼ同じであるため、
少し弄ればtkytkの辞書をほぼ丸々使えます。
が、どちらかというと処理そのものはshioriフォルダと
libフォルダ以下のスクリプト群(KOTORI)が本体です。
そのため、tkytkのサンプルゴーストとは書き方が大幅に変わっています。


# 自動置換

replace.confに
置換前,置換後
の形式で書いてください。
「,」を含む置換は出来ません。
文字コードはUTF-8限定。


# セーブファイル

kagari_savedata.luaにセーブされます。


# SAORIの使用

kagari_saori.confに
辞書内で使用する名前,dllへのパス
の形式で書いてください。
文字コードは基本的になんでも大丈夫なはず。
Shift_JIS推奨。


# ライセンスについて

talkディレクトリ内のファイルは特に断りがない場合は
WTFPLが適用されます。


#その他

lib/nkf/init.dllはluaからnkfの関数を呼び出すためのものです。
nkfのライブラリと静的リンクされています。

lib/luachild.dllはオリジナルのluachildに
luaexの関数(chdir, currentdir, dir, dirent)を移植し、
さらに独自にprocess_terminate関数と__gc関数を追加しています。
また、deprecatedになっていたstrdup,filenoを_strdup,_filenoへ修正しています。
