# はじめに

luaのSHIORIなのでluaについてはある程度理解している前提の説明になる。


# 辞書ファイルの作り方


## 辞書ファイルの格納場所
ghost\master\talkフォルダ以下にアンダースコアから始まらない文字列+拡張子(.lua)


### 例
*認識される*
ghost\master\talk\boot.lua
*認識されない*
ghost\master\boot.lua
ghost\master\talk\boot.txt
ghost\master\talk\_boot.lua


## 辞書の書き方


### 仕様

return {
  {
    passthrough = [true | false],
    anchor  = [true | false],
    id  = [String],
    content = Array | Function | Map[^1] | String,
  },
}

passthroughをtrueにするとreplace.confによる自動置換、自動リンク、
末尾\eの追加などの処理を行わないようになる。
balloon_tooltipとか、余計な文字を追加したくないものに指定すると良い。

anchorをtrueにするとidに指定した文字列を自動リンクするようになる。

idを指定しないとランダムトークで呼ばれる様になる。
(内部的にはidはnilではなく長さ0の文字列)

contentは最終的に文字列が返されるようになっていればok。
また、文字列中の改行コードは無視される。
ついでに、末尾の\eは省略しても付加されるようになっている。

[^1]__tostringのmetamethodを持つもののみ。


### 具体例

return {
  {
    id  = "OnBoot",
    content = "\\0こんにちは！\\e",
  },
  {
    id  = "OnClose",
    content = "\\0ばいば〜い\\-\\e",
  },
  {
    id  = "Event1",
    content = [[
Content
]],
  },
  {
    id  = "Event2",
    content = function(shiori, ref)
      return "Content"
    end,
  },
  {
    id  = "Event3",
    content = function(shiori, ref)
      return "Content1", "Content2"
    end,
  },
  {
    id  = "Event4",
    content = {
      "Content1",
      "Content2",
      "Content3",
    },
  },
}


### Tips


#### 同じイベントのトークを増やす

どちらも起動時に「おはよう！」「こんにちは！」「こんばんは！」の内から
いずれか1つをランダムに返す。


##### 例1

return {
  {
    id  = "OnBoot",
    content = "\\0おはよう！\\e",
  },
  {
    id  = "OnBoot",
    content = "\\0こんにちは！\\e",
  },
  {
    id  = "OnBoot",
    content = "\\0こんばんは！\\e",
  },
}


##### 例2

return {
  {
    id  = "OnBoot",
    content = {
      "\\0おはよう！\\e",
      "\\0こんにちは！\\e",
      "\\0こんばんは！\\e",
    },
  },
}


##### 注意

例1と例2を両方使うと選択される確率が変わってくる。
意図的に確率を変えたいのでなければid毎に書き方を統一すべし。

return {
  {
    id  = "OnBoot",
    content = "\\0おはよう！\\e",     -- 1/4
  },
  {
    id  = "OnBoot",
    content = "\\0こんにちは！\\e",   -- 1/4
  },
  {
    id  = "OnBoot",
    content = "\\0こんばんは！\\e",   -- 1/4
  },
  {
    id  = "OnBoot",
    content = {
      "\\0おはよう！\\e",             -- 1/12
      "\\0こんにちは！\\e",           -- 1/12
      "\\0こんばんは！\\e",           -- 1/12
    },
  },
}


## チェイントーク
後述するshiori:reserveTalk(id[, index])を用いる他に、
coroutineを利用する方法がある。
  {
    id  = "OnEvent",
    content = function(shiori, talk)
      coroutine.yield("\\0やっふー")
      coroutine.yield("\\0逸見", "\\0真理雄")
      return "\\0ははー"
    end,
  },
のように書いておくと、
OnEventが呼ばれる度に、
1."やっふー"
2."逸見"か"真理雄"のどちらか
3."ははー"
が順番に表示される。
かならず1から表示される点に注意。


## 辞書のfunctionの引数

return {
  {
    id  = "Event",
    content = function(shiori, ref) -- ←このshioriとrefの説明
      return "\\0やっほー\\e"
    end,
  },
}


### shiori

shiori:talkRandom() --  ランダムトークを返す
shiori:talkPrevious() --  直前に話したランダムトークを返す
shiori:reserveTalk(id[, index]) -- トークの予約をする
shiori:saori(id)

#### shiori:reserveTalk(id[, index = 1])
しゃべるトークの予約を行う。
indexは省略すると次のトークを予約することになる。


#### shiori:saori(id)

function(shiori, ref)
  local module  = shiori:saori("Test")
  module("Argument0", "Argument1")
  local ret = module("test", 100)
  print(ret())  -- Resultの値
  print(ret[0]) -- Value0の値
  print(ret[1]) -- Value1の値
  -- エラーを考慮しなければ一行でも書ける。
  local result  = shiori:saori("Test")("Argument")()
end


#### shiori.var(key)

SHIORI内で呼び出せる変数を保持する関数。
要素の最初の文字を_(アンダースコア)にすると
変数がファイルに保存されない。
また、これに保存した変数は文字列内から${}を使って参照できる。
ただし、tostringで文字列化しているので、配列や関数などは
ただしく置換されないので注意。

変数弄る度に呼ぶのが面倒なので
local __  = shiori.varとしておくと幸せ。

*これだけはshiori:var()ではなくshiori.var()で呼ぶこと。*

function(shiori, ref)
  local __  = shiori.var
  shiori.var("Test", "テスト")
  __("Var1", true)
  __("Var2", 100)
  __("Var3", {name = "りんご", num = 3})
  __("Var1", nil) -- 削除
  local var = shiori.var("Test")
  return "\\0あーあー、" .. var .. "${Test}\e" -- "\\0あーあー、テストテスト\e"
end


### ref

Reference*の配列

function(shiori, ref)
  return "\0Reference0は" .. ref[0] .. "だよ。\e"
end


#### 注意

luaの配列はデフォルトでは要素は1から始まるので
Reference*を0から順番に処理したいときは
for i, v in ipairs(ref) do
  do_something(v)
end
ではなく
for i = 0, #ref + 1 do
  do_something(ref[i])
end
とする必要がある。

