# 0108_memory1

MMUを有効にします。

単にキャッシュを有効にすると、必要ないところまでキャッシュされ、正しく動かない可能性があります。
そのため、アドレスごとにキャッシュを制御して、正しく動作させる必要があります。
具体的には、GPU領域とI/O領域以降はキャッシュなし、その他はキャッシュあり。
なお、0104_cacheのキャッシュ制御は無効にしないとフリーズするので注意。
メモリマップは以下の通り

RaspberryPi1/Zeroの場合
┌────────┐0x00000000
｜割り込みテーブル｜
├────────┤0x00004000
｜MMUテーブル     ｜
├────────┤0x00008000
｜                ｜
｜                ｜
｜カーネル他      ｜
｜                ｜
｜                ｜
├────────┤0x1E000000(GPU 16MBの場合)
｜                ｜
｜                ｜
｜GPU             ｜
｜                ｜
｜                ｜
├────────┤0x1F000000
｜空き領域        ｜
├────────┤0x20000000
｜I/O             ｜
├────────┤0x21000000
｜                ｜
｜                ｜
｜未使用          ｜
｜                ｜
｜                ｜
└────────┘

RaspberryPi2/3の場合
┌────────┐0x00000000
｜割り込みテーブル｜
├────────┤0x00004000
｜MMUテーブル     ｜
├────────┤0x00008000
｜                ｜
｜                ｜
｜カーネル他      ｜
｜                ｜
｜                ｜
├────────┤0x3E000000(GPU 16MBの場合)
｜                ｜
｜                ｜
｜GPU             ｜
｜                ｜
｜                ｜
├────────┤0x3F000000
｜I/O             ｜
├────────┤0x40000000
｜Local Peripheral｜
├────────┤0x41000000
｜                ｜
｜                ｜
｜未使用          ｜
｜                ｜
｜                ｜
└────────┘

RaspberryPi4の場合
┌────────┐0x00000000
｜割り込みテーブル｜
├────────┤0x00004000
｜MMUテーブル     ｜
├────────┤0x00008000
｜                ｜
｜                ｜
｜カーネル他      ｜
｜                ｜
｜                ｜
├────────┤0x3E000000(GPU 16MBの場合)
｜                ｜
｜                ｜
｜GPU             ｜
｜                ｜
｜                ｜
├────────┤0x3F000000
｜                ｜
｜                ｜
｜空き領域        ｜
｜                ｜
｜                ｜
├────────┤0x80000000(2GBモデルの場合)
｜                ｜0xFE000000(4GBモデルの場合)
｜                ｜
｜未使用          ｜
｜                ｜
｜                ｜
├────────┤0xFE000000
｜I/O             ｜
├────────┤0xFF800000
｜Local Peripheral｜
└────────┘0xFFFFFFFF

初期化手順)
・mailboxでGPUからGPUメモリ領域のアドレスを取得
・0x00000000～GPU下端アドレス:キャッシュあり
・GPU下端アドレス～GPU上端アドレス:キャッシュなし
・GPU上端アドレス～I/O下端アドレス:キャッシュあり
・I/O下端アドレス～:キャッシュなし
・上記4エリアの情報(テーブル)を0x00004000～0x00008000に書き込む
・ドメインアクセス制御レジスタを設定
・TLB,分岐予測器アレイ,命令キャッシュを無効にする
・データキャッシュを無効にする
・TTBCR, TTBR0の書き換え
・MMUを有効にする
