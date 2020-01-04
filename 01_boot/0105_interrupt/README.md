# 0105_interrupt

割り込みテーブルを設定します。(特に使用はしません)

割り込みが発生した場合、発生原因により0x00000000～0x00000020にジャンプします。
このアドレスにジャンプ命令を設定しておけば、割り込みコードを実行できます。
kernel.imgが0x00000000にロードされた場合、割り込み発生時に変な動作をするため、
割り込みテーブルをコードの先頭に記述しておきます。

手順)
・コードの先頭にジャンプ命令を8個並べる
　最初はリセット割り込みなので、メインコードにジャンプ
　それ以外はハングさせる
・先頭のジャンプ命令8個を0x00000000にコピーする
　リセット割り込みのみ書き換えが必要なので注意
・ジャンプ命令用のアドレステーブル7個を生成し0x00000020に書き込む
