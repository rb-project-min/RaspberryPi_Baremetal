	.section ".text"
	.global _start
	.balign 0x4000
	.arm
_start:
// ================================================================
//  main関数にジャンプする
// ================================================================
	mov		sp, #0x800000					// スタックポインタを適当に設定
	bl		main

// ================================================================
//  main関数から戻った場合は無限ループ
// ================================================================
hang:
	b		.
