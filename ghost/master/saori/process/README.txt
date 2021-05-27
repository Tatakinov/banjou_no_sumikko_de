# このソフトウェアについて

子プロセスと相互通信するためのSAORIです。
※現状Shift_JIS以外の入力を前提とした動作になっています。


# 使い方

uniqueidでイベントを受信したいゴーストのuniqueidを登録する。
spawnで子プロセスを起動。
spawnの戻り値(Result)が起動したプロセスの識別子なので変数に保存する。
sendで文字列を子プロセスへ送信する。
子プロセスが出力した文字列が一行ずつ*EventID*に送られてくる。
処理が終わったらdespawnで子プロセスを終了させる。


## UniqueIDの登録

### 概要

イベントを受信したいゴーストを登録する。
一度登録したらunloadされるまで登録状態は維持される。
が、何度送っても問題ない。

### 説明

uniqueid str

- str
  ゴーストのuniqueid。

### 例

uniqueid foobar_1234_x_5678


## 起動

### 概要

プロセスを起動させる。

### 説明

spawn path argument chdir event_name

- path
  プログラムのパス。
  パスにスペースを含んでいても""で囲う必要は無い。
  必須。

- argument
  コマンドライン引数。
  デフォルトでは無し。

- chdir
  プログラムの作業フォルダを変更するか否か。
  true/falseを指定する。
  デフォルトはtrue。

- event_name
  プログラムが出力した文字列を送るSHIORIのEvent名。
  デフォルトはOnReceiveFromChildProcess

### 戻り値

起動に成功するとResult: 0以上の整数を返す。
失敗時は-1。

### 例

spawn ping.exe "example.com" false


## 送信

### 概要

子プロセスの標準入力へ文字列を送信する。
一行ずつしか送れない。

### 説明

send id str

- id
  spawn時に送られてきたプロセスの識別子。

- str
  子プロセスの標準入力へ送信する文字列。
  末尾に改行コード(\x0d0a)が自動で付加される。
  改行コードを含んだ文字列は送信できない。

### 例

send Hello, World!


## 受信

### 概要

子プロセスが標準出力に出力した文字列を
一行毎にイベントを発生させてSHIORIへ伝達する。
また、各行の末尾の改行コードは削除される。

- OnReceiveFromChildProcess
  Reference0: プロセスの識別子
  Reference1: 出力された文字列

- spawn時にevent_nameを↑以外の文字列に指定した場合
  Reference0: 出力された文字列

### 例

各SHIORI毎に違うので省略。


## 終了

### 概要

起動中の子プロセスを終了させる。

### 例

despawn id

- id
  spawn時に送られてきたプロセスの識別子。
