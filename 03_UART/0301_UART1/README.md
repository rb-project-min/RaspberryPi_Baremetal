# 0301_UART1

UART1を使用してシリアルコンソール

GPIO14,15をUART1に設定してシリアルコンソールとして使用します。  
なお、出力電圧3.3Vのため、RS232Cと直接接続しないでください。(電圧が異なるため)  
電圧変換を行うか、3.3VUART変換ケーブルを使用してください。  
FTDI USBシリアル変換ケーブル(3.3V) で動作確認。

手順)  
・GPIO14,15をALT5設定にする(UART1)  
・mailboxにてCoreクロックを取得し、ボーレートを設定する  
・UART1を有効化する  
・テストメッセージを送信する
