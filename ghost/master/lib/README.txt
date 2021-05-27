class           -- 必須。classを作るのに使っている。
clipboard       -- 任意。クリップボードへ文字列をコピーする。
                    改行文字を含んでいてもOK。
clone           -- 任意。kifu_playerで使用。
conv            -- 必須。文字コード変換を司る。
fh              -- 任意。non-blockingなpipeを作るのに使う。
kifu_player     -- 任意。将棋の盤面を管理するのに必要。
lpeg            -- 任意。kifu_playerで利用。
                    正規表現の()が使えるので入れておいた方がいいかも。
lua-utf8        -- ほぼ必須。SHIORIのAnchorの処理で利用している。
                    lua5.3以降にはutf8ライブラリがあるので代用出来るかも。
luachild        -- ほぼ必須。SAORI-Basicを使わなければいらない。
nkf             -- 必須。文字コード変換に利用。
nop             -- 任意。文法エラーを回避するためのもの。
path            -- 必須。辞書ファイルを読み込んだりするのに使っている。
process         -- 重要。SAORI-Basicを使わなければいらない。
rand            -- 任意。乱数を取得するのに使う。
sakura_script   -- 任意。使いやすいと思ったがそうでもなかった。
saori_*         -- ほぼ必須。SAORIを使わなければいらない。
ss_bind_updater -- 任意。SakuraScriptの\![bind]の重複を減らすためのもの。
string_buffer   -- 必須。全体で使っている。文字連結が速い。
trie            -- 必須。SHIORIのAnchorの処理で使っている。
ukagaka_module  -- 必須。Basewareとのやりとりなどで使っている。
usi             -- 任意。将棋エンジンとのやりとりで使っている。
