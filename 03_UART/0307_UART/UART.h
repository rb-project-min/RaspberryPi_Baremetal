#ifndef UART_H
#define UART_H
#include <stdint.h>
#include <stdbool.h>

#include "rpi.h"

/* データレジスタ */
// bit31-12:			予約 0固定
// bit11:	 OE			オーバーランエラー
// bit10:	 BE			ブレークエラー
// bit 9:	 PE			パリティエラー
// bit 8:	 FE			フレーミングエラー
// bit 7- 0: DATA		RX/TXデータ
#define UART_DR		(*(volatile uint32_t*)(UART_BASE + 0x00))

/* RSRECR Register */
// bit31- 4:			予約 0固定
// bit 3:	 OE			オーバーランエラー
// bit 2:	 BE			ブレークエラー
// bit 1:	 PE			パリティエラー
// bit 0:	 FE			フレーミングエラー
#define UART_RSRECR	(*(volatile uint32_t*)(UART_BASE + 0x04))

/* フラグレジスタ */
// bit31- 9:			予約 0固定
// bit 8:	 RI			リンクインジケータ(未サポート)
// bit 7:	 TXFE		送信FIFO エンプティ
// bit 6:	 RXFF		受信FIFO フル
// bit 5:	 TXFF		送信FIFO フル
// bit 4:	 RXFE		受信FIFO エンプティ
// bit 3:	 BUSY		UART ビジー
// bit 2:	 DCD		データキャリア検出(未サポート)
// bit 1:	 DSR		データセット準備完了(未サポート)
// bit 0:	 CTS		送信クリア
#define UART_FR		(*(volatile uint32_t*)(UART_BASE + 0x18))

/* 整数ボーレート除数レジスタ */
// bit31-16:			予約 0固定
// bit15- 0: IBRD		バンドレートディバイダー(整数部分)
//						IBRD = 3,000,000/(16*Baudrate)
#define UART_IBRD		(*(volatile uint32_t*)(UART_BASE + 0x24))

/* 小数ボーレート除数レジスタ */
// bit31- 6:			予約 0固定
// bit 5- 0: FBRD		バンドレートディバイダー(小数部分)
//						FBRD = (24,000,000/Baudrate-IBRD*128+1)/2
#define UART_FBRD		(*(volatile uint32_t*)(UART_BASE + 0x28))

/* ライン制御レジスタ */
// bit31- 8:			予約 0固定
// bit 7:	 SPS		スティックパリティ 0:無効 1:有効
// bit 6- 5: WLEN		データ長 0:5bit 1:6bit 2:7bit 3:8bit
// bit 4:	 FEN		FIFO有効化 0:無効 1:有効
// bit 3:	 STP2		ストップビット 0:1bit 1:2bit
// bit 2:	 EPS		パリティビット 0:奇数 1:偶数
// bit 1:	 PEN		パリティ有効化 0:無効 1:有効
// bit 0:	 BRK		ブレーク送信 0:しない 1:する
#define UART_LCRH		(*(volatile uint32_t*)(UART_BASE + 0x2C))

/* コントロールレジスタ */
// bit31-16:			予約 0固定
// bit15:	 CTSEN		CTSハードウェアフロー制御 0:無効 1:有効
// bit14:	 RTSEN		RTSハードウェアフロー制御 0:無効 1:有効
// bit13:	 OUT2		未サポート
// bit12:	 OUT1		未サポート
// bit11:	 RTS		送信要求信号 0:HIGH 1:LOW
// bit10:	 DTR		未サポート
// bit 9:	 RXE		受信有効化 0:無効 1:有効
// bit 8:	 TXE		送信有効化 0:無効 1:有効
// bit 7:	 LBE		ループバック 0:無効 1:有効
// bit 6- 3: 			予約 0固定
// bit 2:	 SIRLP		未サポート
// bit 1:	 SIREN		未サポート
// bit 0:	 UARTEN		UART有効化 0:無効 1:有効
#define UART_CR		(*(volatile uint32_t*)(UART_BASE + 0x30))

/* FIFO割り込みレベルレジスタ */
// bit31-12:			予約 0固定
// bit11- 9: RXIFPSEL	未サポート
// bit 8- 6: TXIFPSEL	未サポート
// bit 5- 3: RXIFLSEL	受信FIFO割り込みレベル 0:1/8 1:1/4 2:1/2 3:3/4 4:7/8
// bit 2- 0: TXIFLSEL	送信FIFO割り込みレベル 0:1/8 1:1/4 2:1/2 3:3/4 4:7/8
#define UART_IFLS		(*(volatile uint32_t*)(UART_BASE + 0x34))

/* 割り込みマスクレジスタ */
// bit31-11:			予約 0固定
// bit10:	 OEIM		オーバーランエラー割り込みマスク 0:クリア 1:マスク
// bit 9:	 BEIM		ブレークエラー割り込みマスク 0:クリア 1:マスク
// bit 8:	 PEIM		パリティエラー割り込みマスク 0:クリア 1:マスク
// bit 7:	 FEIM		フレーミングエラー割り込みマスク 0:クリア 1:マスク
// bit 6:	 RTIM		受信タイムアウト割り込みマスク 0:クリア 1:マスク
// bit 5:	 TXIM		送信割り込みマスク 0:クリア 1:マスク
// bit 4:	 RXIM		受信割り込みマスク 0:クリア 1:マスク
// bit 3:	 DSRMIM		未サポート
// bit 2:	 DCDMIM		未サポート
// bit 1:	 CTSMIM		nUARTCTSモデム割り込みマスク 0:クリア 1:マスク
// bit 0:	 RIMIM		未サポート
#define UART_IMSC		(*(volatile uint32_t*)(UART_BASE + 0x28))

/* 割り込みレジスタ(生データ) */
// bit31-11:			予約 0固定
// bit10:	 OERIS		オーバーランエラー割り込み 0:なし 1:あり
// bit 9:	 BERIS		ブレークエラー割り込み 0:なし 1:あり
// bit 8:	 PERIS		パリティエラー割り込み 0:なし 1:あり
// bit 7:	 FERIS		フレーミングエラー割り込み 0:なし 1:あり
// bit 6:	 RTRIS		受信タイムアウト割り込み 0:なし 1:あり
// bit 5:	 TXRIS		送信割り込み 0:なし 1:あり
// bit 4:	 RXRIS		受信割り込み 0:なし 1:あり
// bit 3:	 DSRMRIS	未サポート
// bit 2:	 DCDMRIS	未サポート
// bit 1:	 CTSMRIS	nUARTCTSモデム割り込み 0:なし 1:あり
// bit 0:	 RIMRIS		未サポート
#define UART_RIS		(*(volatile uint32_t*)(UART_BASE + 0x3C))

/* 割り込みレジスタ(マスク) */
// bit31-11:			予約 0固定
// bit10:	 OEMIS		オーバーランエラー割り込み 0:なし 1:あり
// bit 9:	 BEMIS		ブレークエラー割り込み 0:なし 1:あり
// bit 8:	 PEMIS		パリティエラー割り込み 0:なし 1:あり
// bit 7:	 FEMIS		フレーミングエラー割り込み 0:なし 1:あり
// bit 6:	 RTMIS		受信タイムアウト割り込み 0:なし 1:あり
// bit 5:	 TXMIS		送信割り込み 0:なし 1:あり
// bit 4:	 RXMIS		受信割り込み 0:なし 1:あり
// bit 3:	 DSRMMIS	未サポート
// bit 2:	 DCDMMIS	未サポート
// bit 1:	 CTSMMIS	nUARTCTSモデム割り込み 0:なし 1:あり
// bit 0:	 RIMMIS		未サポート
#define UART_MIS		(*(volatile uint32_t*)(UART_BASE + 0x40))

/* 割り込みクリアレジスタ */
// bit31-11:			予約 0固定
// bit10:	 OEIC		オーバーランエラー割り込みクリア 0:しない 1:する
// bit 9:	 BEIC		ブレークエラー割り込みクリア 0:しない 1:する
// bit 8:	 PEIC		パリティエラー割り込みクリア 0:しない 1:する
// bit 7:	 FEIC		フレーミングエラー割り込みクリア 0:しない 1:する
// bit 6:	 RTIC		受信タイムアウト割り込みクリア 0:しない 1:する
// bit 5:	 TXIC		送信割り込みクリア 0:しない 1:する
// bit 4:	 RXIC		受信割り込みクリア 0:しない 1:する
// bit 3:	 DSRMIC		未サポート
// bit 2:	 DCDMIC		未サポート
// bit 1:	 CTSMIC		nUARTCTSモデム割り込みクリア 0:しない 1:する
// bit 0:	 RIMIC		未サポート
#define UART_ICR		(*(volatile uint32_t*)(UART_BASE + 0x44))

#define UART_ITCR		(*(volatile uint32_t*)(UART_BASE + 0x80))
#define UART_ITIP		(*(volatile uint32_t*)(UART_BASE + 0x84))
#define UART_ITOP		(*(volatile uint32_t*)(UART_BASE + 0x88))
#define UART_TDR		(*(volatile uint32_t*)(UART_BASE + 0x8C))


#ifndef AUX_BASE
#define AUX_BASE     (RPi_IO_Base_Addr + 0x00215000)

/* Auxiliary Interrupt status  */
#define AUX_IRQ            (*(volatile uint32_t*)(AUX_BASE + 0x00))

/* Auxiliary enables */
#define AUX_ENABLES        (*(volatile uint32_t*)(AUX_BASE + 0x04))
#endif

/* Mini Uart I/O Data */
// bit31- 8:		予約 0固定
// bit 7- 0: RXBUF	受信データバッファ(読込時)
// bit 7- 0: TXBUF	送信データバッファ(書込時)
// bit 7- 0: DLL	Bandrate設定値 下位8bit(DLAB=1時)
#define UART1_IO			(*(volatile uint32_t*)(AUX_BASE + 0x40))

/* Mini Uart Interrupt Enable */
// bit31- 4:		予約 0固定
// bit 3: EDSSI		無効 0固定
// bit 2: ELSI		無効 0固定
// bit 1: ETBEI		送信割り込みの許可(0:禁止 1:許可)
// bit 0: ERBFI		受信割り込みの許可(0:禁止 1:許可)
// bit 7- 0: DLM	Bandrate設定値 上位8bit(DLAB=1時)
#define UART1_IER		(*(volatile uint32_t*)(AUX_BASE + 0x44))

/* Mini Uart Interrupt Identify */
// bit31- 8:		予約 0固定
// bit 7: FRMERR	無効(読込時) 0固定
// bit 6: TEMT		無効(読込時) 0固定
// bit 5- 4:		予約 0固定
// bit 3: IRTO		無効(読込時) 0固定
// bit 2-1: IRID	割り込みID(読込時)(0:モデム状態 1:送信バッファ 2:受信可能 3:受信ステータス)
// bit 0: IRP		割り込み状態(読込時)(0:割込みあり 1:割込みなし)
//
// bit 7- 6: RCVRT	FIFOトリガレベル(書込時)(0:1Byte 1:4Byte 2:8Byte 3:14Byte)
// bit 5- 4:		予約 0固定
// bit 3: DMAS		DMAモード選択(書込時)(0:通常 1:DMA)
// bit 2: XMITFR	送信バッファクリア(書込時)(0:クリアしない 1:クリアする)
// bit 1: RCVRFR	受信バッファクリア(書込時)(0:クリアしない 1:クリアする)
// bit 0: FIFOEN	FIFOイネーブル(書込時)(0:無効 1:有効)
#define UART1_IIR		(*(volatile uint32_t*)(AUX_BASE + 0x48))

/* Mini Uart Line Control */
#define UART1_LCR		(*(volatile uint32_t*)(AUX_BASE + 0x4C))
/* Mini Uart Modem Control */
#define UART1_MCR		(*(volatile uint32_t*)(AUX_BASE + 0x50))
/* Mini Uart Line Status */
#define UART1_LSR		(*(volatile uint32_t*)(AUX_BASE + 0x54))
/* Mini Uart Modem Status */
#define UART1_MSR		(*(volatile uint32_t*)(AUX_BASE + 0x58))
/* Mini Uart Scratch */
#define UART1_SCRATCH	(*(volatile uint32_t*)(AUX_BASE + 0x5C))
/* Mini Uart Extra Control */
#define UART1_CNTL		(*(volatile uint32_t*)(AUX_BASE + 0x60))
/* Mini Uart Extra Status */
#define UART1_STAT		(*(volatile uint32_t*)(AUX_BASE + 0x64))
/* Mini Uart Baudrate */
#define UART1_BAUD		(*(volatile uint32_t*)(AUX_BASE + 0x68))


uint32_t uart_init(uint32_t id, uint32_t Baud);

void uart_putc(uint32_t id, char byte);
void uart_puts(uint32_t id, const char *str);
char uart_getc(uint32_t id);

#endif
