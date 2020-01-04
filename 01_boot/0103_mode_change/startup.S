	.section ".text"
	.global _start
	.balign 0x4000
	.arm
_start:
// ================================================================
//  IO_Base_Addr, LocalPeripheralsAddr�̐ݒ�
// ================================================================
	mrc		p15, 0, r4, c0, c0, 0			// MIDR�̓ǂݍ���
	bic		r4, r4, #0x0F					// RevisionID���N���A(�O�̂���)

	mov		r1, #0x20000000					// IO_Base_Addr(Raspberry pi 1/Zero�̏ꍇ)
	mov		r2, #0x00000000					// LocalPeripheralsAddr(Raspberry pi 1/Zero�̏ꍇ)

	ldr		r3, =0x410FB760					// ARM11(Raspberry pi 1/Zero)
	cmp		r4, r3

	movne	r1, #0x3F000000					// IO_Base_Addr(Raspberry pi 1/Zero�̏ꍇ)
	movne	r2, #0x40000000					// LocalPeripheralsAddr(Raspberry pi 1/Zero�̏ꍇ)

	ldrne	r3, =0x410FC070					// Cortex-A7(Raspberry pi 2)
	cmpne	r4, r3
	ldrne	r3, =0x410FD030					// Cortex-A53(Raspberry pi 3)
	cmpne	r4, r3

	movne	r1, #0xFE000000					// IO_Base_Addr(Raspberry pi 4�̏ꍇ)
	orrne	r2, r1, #0x01800000				// LocalPeripheralsAddr(Raspberry pi 4�̏ꍇ)

	str		r1, RPi_IO_Base_Addr			// IO_Base_Addr�̕ۑ�
	str		r2, RPi_LocalPeripheralsAddr	// LocalPeripheralsAddr�̕ۑ�

// ================================================================
//  Raspberry pi 1/Zero�ł͒���cpsr�ɏ�������
//  Raspberry pi 2�ȍ~��CPU���[�h��HYP_MODE�̏ꍇ�A
//  eret���g�p���ăV�X�e�����[�h�Ɉڍs
// ================================================================
    mrs		r0, cpsr				// CPU���[�h�r�b�g���܂�CPSR���W�X�^���R�s�[
 	and		r1, r0, #0x1F			// CPU���[�h�r�b�g�̒��o
 	cmp		r1, #0x1A				// HYP_MODE�̊m�F
	orr		r0, r0, #0xDF			// �V�X�e�����[�h���Z�b�g(IRQ/FIQ�͖���)
    msreq	spsr_cxsf, r0			// (HYP_MODE�̏ꍇ)SPSR���W�X�^�փR�s�[
	addeq	lr, pc, #4				// (HYP_MODE�̏ꍇ)�߂�A�h���X���Z�o

	// �R���p�C���G���[���o��̂� .word �Œ��ڎw��
	.word	0x012ef30e				// msreq ELR_hyp, lr	(HYP_MODE�̏ꍇ)�߂�A�h���X���R�s�[
	.word	0x0160006e				// ereteq				(HYP_MODE�̏ꍇ)�V�X�e�����[�h�Ń��^�[��

	// eret�ɂ��߂��
    mrs		r0, cpsr				// CPU���[�h�r�b�g���܂�CPSR���W�X�^���R�s�[
	orr		r0, r0, #0xDF			// �V�X�e�����[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r0				// �V�X�e�����[�h�֐؂�ւ�

// ================================================================
//  �X�^�b�N�|�C���^��ݒ肵��main�֐��փW�����v
// ================================================================
	mov		sp, #0x800000					// �X�^�b�N�|�C���^��K���ɐݒ�
	b		main							// main�֐��փW�����v
hang:
	b		.								// �������[�v

	.globl RPi_IO_Base_Addr
RPi_IO_Base_Addr:				// Peripheral Base Addr
	.word	0x20000000

	.globl RPi_LocalPeripheralsAddr
RPi_LocalPeripheralsAddr:		// Local Peripherals Addr
	.word	0x40000000
