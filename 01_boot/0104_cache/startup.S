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
//  NSACR(��Z�L���A�A�N�Z�X���䃌�W�X�^)�̐ݒ�
//  mcrne���g���Ɖ��̂��t���[�Y����̂ŃW�����v���g�p
// ================================================================
	mrc		p15, 0, r0, c1, c1, 2	// NSACR(��Z�L���A�A�N�Z�X���䃌�W�X�^)
	and		r1, r0, #0x0C00
	cmp		r1, #0x0C00				// ���������_���j�b�g���L�����`�F�b�N
	beq		1f						// ���ɗL���Ȃ�W�����v
	orr		r0, r0, #0x0C00			// �Z�L���A���[�h,��Z�L���A���[�h�̃A�N�Z�X����
	mcr		p15, 0, r0, c1, c1, 2	// NSACR(��Z�L���A�A�N�Z�X���䃌�W�X�^)

// ================================================================
//  FPU���I�����C���ɂ���
//  Raspberry pi 4�ł�isb���g��Ȃ��Ɖ��̂��t���[�Y����
// ================================================================
1:	mrc		p15, 0, r0, c1, c0, 2	// CPACR(�A�[�L�e�N�`���@�\�A�N�Z�X���䃌�W�X�^)
	orr		r0, #0xF00000			// �P���x/�{���x���������_���Z�̗L����
	mcr		p15, 0, r0, c1, c0, 2	// CPACR(�A�[�L�e�N�`���@�\�A�N�Z�X���䃌�W�X�^)

	ldr		r11, RPi_LocalPeripheralsAddr	// RaspberryPi1/Zero�ł�0x00000000�ƂȂ�
	cmp		r11, #0					// RaspberryPi1/Zero�`�F�b�N(isb���ߗp)
	beq		1f						// isb���߂��X�L�b�v

	// �R���p�C���G���[���o��̂� .word �Œ��ڎw��
	.word	0xF57FF06F				// isb

1:	mov		r0, #0x40000000			// VFP�L����
	vmsr	fpexc, r0				// FPEXC��������

// ================================================================
//  �L���b�V����L���ɂ���
// ================================================================
    mrc		p15, 0, r0, c1, c0, 0	// SCTLR(�V�X�e���R���g���[�����W�X�^)
	orr		r0, r0, #4
	orr		r0, r0, #6144			// C bit, Z bit, I bit���Z�b�g(�f�[�^�L���b�V��,�t���[�\��,���߃L���b�V���̗L����) 
	mcr		p15, 0, r1, c1, c0, 0	// SCTLR

	cmp		r11, #0					// RaspberryPi1/Zero�`�F�b�N(dsb/isb���ߗp)
	beq		1f						// dsb/isb���߂��X�L�b�v

	// �R���p�C���G���[���o��̂� .word �Œ��ڎw��
	.word	0xF57FF04F				// dsb
	.word	0xF57FF06F				// isb

// ================================================================
//  �X�^�b�N�|�C���^��ݒ肵��main�֐��փW�����v
// ================================================================
1:	mov		sp, #0x800000					// �X�^�b�N�|�C���^��K���ɐݒ�
	b		main							// main�֐��փW�����v
hang:
	b		.								// �������[�v

	.globl RPi_IO_Base_Addr
RPi_IO_Base_Addr:				// Peripheral Base Addr
	.word	0x20000000

	.globl RPi_LocalPeripheralsAddr
RPi_LocalPeripheralsAddr:		// Local Peripherals Addr
	.word	0x40000000
