#COCOAについて

オセロの盤面操作&思考が出来るSAORIです。


# 使い方


## 初期化
saori.call("init")

### 戻り値
なし


## 盤面を取得する
saori.call("board")

### 戻り値
Result: "color00,color10,color20,...,colorxy,...,color99"
-- example: Resutlt:0,0,1,1,1,2,0,0,0,...

カンマ区切りの各座標の石の種類
0はなし、1は黒の石、2は白の石


## 駒を置く
saori.call("put", x, y)

### 戻り値
なし

ただし0<=x<=7,0<=y<=7の範囲で、左上を(0,0)とする。


## 手番を取得する
saori.call("teban")

###戻り値
Result: "Black" か "White" のどちらか


## 指し手を生成する
saori.call("genMoves")

## 戻り値
Result: 指し手の数
ValueN: "x,y"


## パスをする
saori.call("pass")

### 戻り値
なし


## パスをしなければならないか調べる
saori.call("isPass")

### 戻り値
Result: "True" か "False"


## 双方置く場所が無い=ゲーム終了したか
saori.call("isGameOver")

### 戻り値
Result: "True" か "False"
"True"だった場合は以下も含む
Value0: 黒の石の数
Value1: 白の石の数


## 思考エンジンに思考させる
saori.call("move", depth)

### 戻り値
Result: "x,y"
Value0: "x,y"
Value1: "score"

depthは探索深さ(≒つよさ)
x, yは指し手の座標
scoreは評価値
