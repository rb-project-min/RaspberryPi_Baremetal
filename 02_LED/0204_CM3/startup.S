	.section ".text"
	.global _start
	.balign 0x4000
	.arm
_start:
// ================================================================
//  0x0000�Ƀ��[�h�����ꍇ�̊��荞�݃G���A 0x0000�ɃR�s�[����
//  �W�����v��A�h���X�͌�ɐ�������
// ================================================================
	b		_reset
	ldr		pc, _undefined_instruction_vector_h
	ldr		pc, _software_interrupt_vector_h
	ldr		pc, _prefetch_abort_vector_h
	ldr		pc, _data_abort_vector_h
	b		.
	ldr		pc, _interrupt_vector_h
	ldr		pc, _fast_interrupt_vector_h

_reset_h:							.word   _start
_undefined_instruction_vector_h:	.word   hang
_software_interrupt_vector_h:		.word   hang
_prefetch_abort_vector_h:			.word   hang
_data_abort_vector_h:				.word   hang
_interrupt_vector_h:				.word   hang
_fast_interrupt_vector_h:			.word   hang

_reset:
// ================================================================
//  ����CPU���[�h�ƃu�[�g�A�h���X��ۑ�����
// ================================================================
	adr		r11, _start				// �u�[�g�A�h���X
	sub		r10, r11, #0x8000		// �u�[�g�A�h���X�Ǝ��A�h���X�̃I�t�Z�b�g
	str		r10, RPi_BootOffset		// �u�[�g�I�t�Z�b�g�̕ۑ�

// ================================================================
//  IO_Base_Addr, LocalPeripheralsAddr�̐ݒ�
// ================================================================
	mrc		p15, 0, r4, c0, c0, 0			// MIDR�̓ǂݍ���
	bic		r4, r4, #0x0F					// RevisionID���N���A

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
//  ���荞�݃e�[�u����0x0000�ɃR�s�[
// ================================================================
	mov     r1, #0x0000						// �R�s�[��A�h���X
	mov		r0, r11							// �R�s�[���A�h���X
    ldmia   r0!, {r2, r3, r4, r5, r6, r7, r8, r9}
	mov		r2, r3							// ���Z�b�g���荞�ݖ��߂���������
    stmia   r1!, {r2, r3, r4, r5, r6, r7, r8, r9}

	adr		r2, _start						// ���Z�b�g���荞�݃A�h���X
	adr		r3, hang						// ����`���荞�݃A�h���X
	mov		r4, r3							// �\�t�g�E�F�A���荞�݃A�h���X
	mov		r5, r3							// �v���t�F�b�`�A�{�[�g���荞�݃A�h���X
	mov		r6, r3							// �f�[�^�A�{�[�g���荞�݃A�h���X
	mov		r7, r3							// IRQ���荞�݃A�h���X
	mov		r8, r3							// FIQ���荞�݃A�h���X
    stmia   r1, {r2, r3, r4, r5, r6, r7, r8}	// ���荞�݃W�����v�����������
    stmia   r0, {r2, r3, r4, r5, r6, r7, r8}	// ���荞�݃W�����v�����������

// ================================================================
//  CPU���[�h��HYP_MODE�̏ꍇ�ASVC_MODE�Ɉڍs
//  Raspberry pi 1/Zero�ł͋N����SVC_MODE�̂��ߕs�v
// ================================================================
multicore_start:
    mrs		r0, cpsr				// CPU���[�h�r�b�g���܂�CPSR���W�X�^���R�s�[
 	and		r1, r0, #0x1F			// CPU���[�h�r�b�g�̒��o
 	cmp		r1, #0x1A				// HYP_MODE�̊m�F
	orr		r0, r0, #0xDF			// �V�X�e�����[�h���Z�b�g(IRQ/FIQ�͖���)
    msreq	spsr_cxsf, r0			// (HYP_MODE�̏ꍇ)SPSR���W�X�^�փR�s�[
	addeq	lr, pc, #4				// (HYP_MODE�̏ꍇ)�߂�A�h���X���Z�o

	// �R���p�C���G���[���o��̂� .word �Œ��ڎw��
	.word	0x012ef30e				// msreq ELR_hyp, lr	(HYP_MODE�̏ꍇ)�߂�A�h���X���R�s�[
	.word	0x0160006e				// ereteq				(HYP_MODE�̏ꍇ)�V�X�e�����[�h�Ń��^�[��

// ================================================================
//  SVC���[�h�ȊO�̃X�^�b�N�|�C���^�̃Z�b�g�A�b�v
// ================================================================
	ldr		r0, =__FIQ_stack_core0	// FIQ���[�h�p�X�^�b�N�|�C���^(Core 0)
	ldr		r1, =__IRQ_stack_core0	// IRQ���[�h�p�X�^�b�N�|�C���^(Core 0)
	ldr		r2, =__SVC_stack_core0	// SVC���[�h�p�X�^�b�N�|�C���^(Core 0)
	ldr		r3, =__ABT_stack_core0	// �A�{�[�g���[�h�p�X�^�b�N�|�C���^(Core 0)
	ldr		r4, =__UND_stack_core0	// ����`���[�h�p�X�^�b�N�|�C���^(Core 0)

	ldr		r5, RPi_LocalPeripheralsAddr	// �V���O���R�A���ʗp��LocalPeripheralsAddr��ǂݍ���
	cmp		r5, #0					// �A�h���X���Ȃ��ꍇ�̓V���O���R�A

	mrcne	p15, 0, r5, c0, c0, 5	// Core ID�̓ǂݍ���(ARM7/8)
	andnes	r5, r5, #0x03			// Core ID�̂ݒ��o(���ł�0��r)

	ldrne	r0, =__FIQ_stack_core1	// FIQ���[�h�p�X�^�b�N�|�C���^(Core 1)
	ldrne	r1, =__IRQ_stack_core1	// IRQ���[�h�p�X�^�b�N�|�C���^(Core 1)
	ldrne	r2, =__SVC_stack_core1	// SVC���[�h�p�X�^�b�N�|�C���^(Core 1)
	ldrne	r3, =__ABT_stack_core1	// �A�{�[�g���[�h�p�X�^�b�N�|�C���^(Core 1)
	ldrne	r4, =__UND_stack_core1	// ����`���[�h�p�X�^�b�N�|�C���^(Core 1)
	cmpne	r5, #0x01

	ldrne	r0, =__FIQ_stack_core2	// FIQ���[�h�p�X�^�b�N�|�C���^(Core 2)
	ldrne	r1, =__IRQ_stack_core2	// IRQ���[�h�p�X�^�b�N�|�C���^(Core 2)
	ldrne	r2, =__SVC_stack_core2	// SVC���[�h�p�X�^�b�N�|�C���^(Core 2)
	ldrne	r3, =__ABT_stack_core2	// �A�{�[�g���[�h�p�X�^�b�N�|�C���^(Core 2)
	ldrne	r4, =__UND_stack_core2	// ����`���[�h�p�X�^�b�N�|�C���^(Core 2)
	cmpne	r5, #0x02

	ldrne	r0, =__FIQ_stack_core3	// FIQ���[�h�p�X�^�b�N�|�C���^(Core 3)
	ldrne	r1, =__IRQ_stack_core3	// IRQ���[�h�p�X�^�b�N�|�C���^(Core 3)
	ldrne	r2, =__SVC_stack_core3	// SVC���[�h�p�X�^�b�N�|�C���^(Core 3)
	ldrne	r3, =__ABT_stack_core3	// �A�{�[�g���[�h�p�X�^�b�N�|�C���^(Core 3)
	ldrne	r4, =__UND_stack_core3	// ����`���[�h�p�X�^�b�N�|�C���^(Core 3)

	ldr		r7, RPi_BootOffset		// �u�[�g�I�t�Z�b�g
									// (Core1�ȍ~��_start��ʂ�Ȃ�����,�����œǂݍ���)
	add		r0, r0, r7				// FIQ���[�h�p�X�^�b�N�|�C���^�̃A�h���X�␳
	add		r1, r1, r7				// IRQ���[�h�p�X�^�b�N�|�C���^�̃A�h���X�␳
	add		r2, r2, r7				// SVC���[�h�p�X�^�b�N�|�C���^�̃A�h���X�␳
	add		r3, r3, r7				// �A�{�[�g���[�h�p�X�^�b�N�|�C���^�̃A�h���X�␳
	add		r4, r4, r7				// ����`���[�h�p�X�^�b�N�|�C���^�̃A�h���X�␳

    mrs		r6, cpsr				// CPU���[�h�r�b�g���܂�CPSR���W�X�^���R�s�[
	bic		r6, r6, #0x1F
	orr		r6, r6, #0xD1			// FIQ���[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// FIQ���[�h�֐؂�ւ�
	mov		sp, r0

	bic		r6, r6, #0x1F
	orr		r6, r6, #0xD2			// IRQ���[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// IRQ���[�h�֐؂�ւ�
	mov		sp, r1

	bic		r6, r6, #0x1F
	orr		r6, r6, #0xD3			// SVC���[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// SVC���[�h�֐؂�ւ�
	mov		sp, r2

	bic		r6, r6, #0x1F
	orr		r6, r6, #0xD7			// �A�{�[�g���[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// �A�{�[�g���[�h�֐؂�ւ�
	mov		sp, r3

	bic		r6, r6, #0x1F
	orr		r6, r6, #0xDB			// ����`���[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// ����`���[�h�֐؂�ւ�
	mov		sp, r4

	orr		r6, r6, #0xDF			// �V�X�e�����[�h���Z�b�g(IRQ/FIQ�͖���)
    msr		CPSR_c, r6				// �V�X�e�����[�h�֐؂�ւ�
// ================================================================
//  �V�X�e�����[�h�̃X�^�b�N�|�C���^�̃Z�b�g�A�b�v
//  STACK_SIZE���`���Ă���ꍇ�͂��̒l��D��
// ================================================================
#ifdef STACK_SIZE
	ldr		r2, =STACK_SIZE
#else
	mov		r2, #32768
#endif
	ldr		r4, =__stack_end		// �X�^�b�N�̈扺�[
	add		r4, r4, r7				// �X�^�b�N�̈扺�[�̃A�h���X�␳

	add		sp, r4, r2				// �X�^�b�N�̈��[(Core 0)
	cmp		r5, #0x00

	addne	sp, sp, r2				// �X�^�b�N�̈��[(Core 1)
	cmpne	r5, #0x01

	addne	sp, sp, r2				// �X�^�b�N�̈��[(Core 2)
	cmpne	r5, #0x02

	addne	sp, sp, r2				// �X�^�b�N�̈��[(Core 3)

	cmp		r5, #0x00
	bne		memory_setup_finish		// Core 1�ȍ~�̏ꍇ�̓��������������X�L�b�v

// ================================================================
//  �������z�u�̌v�Z
// ================================================================
	adr		r0, mbox1				// mailbox�f�[�^�A�h���X
	mov		r1, #8					// mailbox�`�����l��
	bl		mailbox					// mailbox���[�`��(r0, r1�͔�j��)

	ldr		r6, VC_Offset			// GPU���������[
	ldr		r4, VC_Size				// GPU�������T�C�Y

	add		r7, r4, r6				// GPU��������[

	adr		r0, mbox2				// mailbox�f�[�^�A�h���X
	bl		mailbox					// mailbox���[�`��(r0, r1�͔�j��)

	ldr		r2, BoardRevision		// Revision ID

	and		r2, #0x00700000			// �������e�ʃ}�X�N
									// ���^�C�v�̏ꍇ��1GB�ȉ��̂��ߖ���
	cmp		r2, #0x00300000			// 0x00000000:256MB 0x00100000:512MB
									// 0x00200000:1GB   0x00300000:2GB   0x00400000:4GB
	movcc	r8, r7					// 1GB�ȉ��̏ꍇ(�n�C�������͑��݂��Ȃ�)
	moveq	r8, #0x80000000			// 2GB�̏ꍇ
	movhi	r8, #0xFE000000			// 4GB�ȏ�̏ꍇ

// ================================================================
//  �e�[�u���̍쐬
//  1GB�ȏ�̗̈��GPU�Ɠ���ւ��ĘA���̈�Ƃ��Ďg�p����
// ================================================================
	mov		r2, #0x4000

// ���C�������� �`r6
	ldr		r10, =0x00011C0E
	mov		r0, r10					// �L���b�V������ ���C�����������[
	add		r1, r6, r10				// �L���b�V������ ���C����������[
1:	cmp		r0, r1					// ��[�ɓ��B�����ꍇ�Ƀ��[�v������
	strne	r0, [r2], #4			// �e�[�u����������
	addne	r0, r0, #0x00100000		// ���������Z
	bne		1b						// ���[�v

// 1GB�ȏ� r7�`r8
	add		r0, r7, r10				// �L���b�V������ �n�C���������[
	add		r1, r8, r10				// �L���b�V������ �n�C��������[
1:	cmp		r0, r1					// ��[�ɓ��B�����ꍇ�Ƀ��[�v������
	strne	r0, [r2], #4			// �e�[�u����������
	addne	r0, r0, #0x00100000		// ���������Z
	bne		1b						// ���[�v

// GPU r6�`r7
	ldr		r10, =0x00010C02
	add		r0, r6, r10				// �L���b�V���Ȃ� GPU���������[
	add		r1, r7, r10				// �L���b�V���Ȃ� GPU��������[
1:	cmp		r0, r1					// ��[�ɓ��B�����ꍇ�Ƀ��[�v������
	strne	r0, [r2], #4			// �e�[�u����������
	addne	r0, r0, #0x00100000		// ���������Z
	bne		1b						// ���[�v

// I/O�G���A r8�`
	add		r0, r8, r10				// �L���b�V���Ȃ� I/O���������[
	mov		r1, r10					// �L���b�V���Ȃ� I/O��������[(�I�[�o�[�t���[)
1:	cmp		r0, r1					// ��[�ɓ��B�����ꍇ�Ƀ��[�v������
	strne	r0, [r2], #4			// �e�[�u����������
	addne	r0, r0, #0x00100000		// ���������Z
	bne		1b						// ���[�v

memory_setup_finish:
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

	ldr		r11, RPi_LocalPeripheralsAddr
	cmp		r11, #0					// ARM11�`�F�b�N(isb���ߗp)
	beq		1f						// isb���߂��X�L�b�v

	.word	0xF57FF06F				// isb

1:	mov		r0, #0x40000000			// VFP�L����
	vmsr	fpexc, r0				// FPEXC��������

// ================================================================
//  �L���b�V���𖳌��ɂ���
// ================================================================
    mrc		p15, 0, r0, c1, c0, 0	// SCTLR(�V�X�e���R���g���[�����W�X�^)
	bic		r0, r0, #4
	bic		r0, r0, #6144			// C bit, Z bit, I bit���N���A(�f�[�^�L���b�V��,�t���[�\��,���߃L���b�V���̖�����) 
	mcr		p15, 0, r0, c1, c0, 0	// SCTLR

// ================================================================
//  �h���C���A�N�Z�X���䃌�W�X�^�̑S�N���C�A���g�ݒ�
// ================================================================
	ldr		r0,=0x55555555			// �N���C�A���g�ݒ�
	mcr		p15, 0, r0, c3, c0, 0	// DACR�ɏ�������

// ================================================================
//  TLB,����\����A���C,���߃L���b�V���𖳌��ɂ���
// ================================================================
	mov		r0, #0
	mcr		p15, 0, r0, c8, c7, 0	// TLB�̖�����
	mcr		p15, 0, r0, c7, c5, 6	// ����\����A���C�̖�����
	mcr		p15, 0, r0, c7, c5, 0	// ���߃L���b�V���̖�����

// ================================================================
//  �f�[�^�L���b�V���𖳌��ɂ���
// ================================================================
1:	mcr		p15, 0, r0, c7, c6, 2	// �Z�b�g/�E�F�C�ݒ�ŃL���b�V�����C���𖳌���
									// (�����l r0=0x00000000)
	add		r0, r0, #0x20			// �Z�b�g�ԍ� +1
	tst		r0, #0x2000				// �Z�b�g�ԍ��̊m�F
	beq		1b						// �Z�b�g�ԍ����I�[�o�[�t���[����܂Ń��[�v

	bic		r0, r0, #0x2000			// �Z�b�g�ԍ��̃I�[�o�[�t���[���N���A
	add		r0, r0, #0x40000000		// �E�F�C�ԍ� +1
	tst		r0, #0xC0000000			// �E�F�C�ԍ��̊m�F
	bne		1b						// �E�F�C�ԍ����I�[�o�[�t���[����܂Ń��[�v

// ================================================================
//  TTBCR, TTBR0�̏�������
// ================================================================
	mcr		p15, 0, r0, c2, c0, 2	// TTBCR�̏�����(r0=0x00000000)
	mov		r0, #0x4000
	orr		r0, r0, #0x48
	mcr		p15, 0, r0, c2, c0, 0	// TTBR0�̏�������

// ================================================================
//  MMU��L���ɂ���
// ================================================================
    mrc		p15, 0, r0, c1, c0, 0	// SCTLR(�V�X�e���R���g���[�����W�X�^)
    orr		r0, #0x1				// MMU�̗L����
    mcr		p15, 0, r0, c1, c0, 0	// SCTLR(�V�X�e���R���g���[�����W�X�^)

	cmp		r11, #0					// ARM11�`�F�b�N(dsb/isb���ߗp)
	beq		1f						// dsb/isb���߂��X�L�b�v

	.word	0xF57FF04F				// dsb
	.word	0xF57FF06F				// isb

// ================================================================
//  ARM7/8��Core 1�`3�̓R�A�̏��������Ƃ��ăW�����v
//  Core 0�͌p��
// ================================================================
1:	mov		r0, #1
	adr		r1, RPi_CoresReady
	strb	r0, [r1, r5]			// CoreReady�J�E���g�̕ۑ�
	cmp		r5, #0
	bne		SecondarySpin			// Core 1�`3�̃��[�v��

// ================================================================
//  Core 1�`3�̏������v���Z�X���N��
// ================================================================
	cmp		r11, #0					// ARM11�`�F�b�N(�}���`�R�A�����X�L�b�v�p)
	beq		.setup_finish			// �V���O���R�A�̏ꍇ�̓X�L�b�v

    adr		r2, multicore_start		// Core 1�`3�̃Z�b�g�A�b�v�A�h���X
	str		r2, [r11, #0x9C]		// Mailbox3(Core 1)�ɃA�h���X��]��
	str		r2, [r11, #0xAC]		// Mailbox3(Core 2)�ɃA�h���X��]��
	str		r2, [r11, #0xBC]		// Mailbox3(Core 3)�ɃA�h���X��]��
	sev
	ldr		r2, =0x01010101
1:	ldr		r1, RPi_CoresReady
	cmp		r1, r2
	bne		1b						// �S�R�A�̏�������������܂Ń��[�v

// ================================================================
//  main�֐��ɃW�����v����
// ================================================================
.setup_finish:
   	 bl		main

// ================================================================
//  main�֐�����߂����ꍇ�͖������[�v
// ================================================================
hang:
	b		.

// ================================================================
//  Core 1�`3�̃��[�v
// ================================================================
	.balign	4
SecondarySpin:
	mrc		p15, 0, r0, c0, c0, 5
	and		r0, r0, #0x03			// Make core 2 bit bitmask in R0
	ldr		r5, RPi_LocalPeripheralsAddr
	add		r5, r5, #0xCC			// Mailbox3 (Core 0) Read
	mov		r3, #0					// magic
1:	wfe								// �C�x���g�҂��X���[�v
	ldr		r4, [r5, r0, lsl #4]	// Mailbox3 (Core x) Read
	str		r4, [r5, r0, lsl #4]	// Mailbox3 (Core x) ���N���A
	cmp		r4, r3					// Mailbox�ɉ����������܂�Ă��邩�`�F�b�N
	beq		1b						// �����Ȃ��ꍇ�̓��[�v

	mov		r0, #0					// r0 = 0
	ldr		r1, =3138				// r1 = �}�V��ID
	ldr		r2, =0x100				// r2 = ATAGS
	adr		lr, SecondarySpin		// �߂�A�h���X��SecondarySpin�ɂ���
	bx		r4						// �󂯎�����A�h���X�փW�����v

// ================================================================
//  Core�̋N��(��1����:�R�AID, ��2����:���s����֐��̃A�h���X)
// ================================================================
	.balign	4
	.globl CoreExecute
CoreExecute:
	ands	r0, r0, #0x03
	beq		CoreExecuteFail			// Core 0�̏ꍇ�͎��s����

	ldr		r3, RPi_LocalPeripheralsAddr
	cmp		r3, #0
	beq		CoreExecuteFail			// Raspberry Pi 1/Zero�̏ꍇ�͎��s����

	add		r3, r3, #0xCC			// Mailbox3 (Core 0) Read
	ldr		r2, [r3, r0, lsl #4]	// Mailbox�փA�h���X��]��
	cmp		r2, #0
	bne		CoreExecuteFail

	sub		r3, r3, #0x40			// Mailbox3 (Core 0) Write
	str		r1, [r3, r0, lsl #4]	// Mailbox�փA�h���X��]��
	sev								// ���ׂẴR�A�𕜋A����
	mov		r0, #1					// �߂�l 1
	bx		lr						// �߂�
CoreExecuteFail:
	mov		r0, #0					// �߂�l 0
	bx		lr						// �߂�

// ================================================================
//  mailbox�A�N�Z�X
//  void mailbox(void *AlinedBuffer, uint32_t Channel);
// ================================================================
	.balign	4
	.globl mailbox
mailbox:
	ldr		r12, RPi_IO_Base_Addr
	add		r12, r12, #0x0000B800

	bic		r2, r0, #0x0F
	and		r3, r1, #0x0F
	orr		r2, r2, r3

1:	ldr		r3, [r12, #0x98]
	ands	r3, #0x80000000
	bne		1b

	str		r2, [r12, #0xA0]

2:	ldr		r3, [r12, #0x98]
	ands	r3, #0x40000000
	bne		2b

	ldr		r3, [r12, #0x80]
	cmp		r3, r2
	bne		1b

	bx		lr

RPi_CoresReady:
	.word	0x00000000			// �������������R�A��

RPi_BootOffset:
	.word	0x00000000			// �u�[�g�A�h���X�Ǝ��A�h���X�̃I�t�Z�b�g

	.globl RPi_IO_Base_Addr
RPi_IO_Base_Addr:				// Peripheral Base Addr
	.word	0x20000000

	.globl RPi_LocalPeripheralsAddr
RPi_LocalPeripheralsAddr:		// Local Peripherals Addr
	.word	0x40000000

	.balign	16
mbox1:
	.word	0x00000020			// Buffer Length
	.word	0x00000000			// Request
	.word	0x00010006			// RPI_FIRMWARE_GET_VC_MEMORY
	.word	0x00000008			// Data Length
	.word	0x00000000			// Request
	.globl VC_Offset
VC_Offset:
	.word	0x00000000			// Memory Offset
	.globl VC_Size
VC_Size:
	.word	0x00000000			// Memory Size
	.word	0x00000000			// Data End

mbox2:
	.word	0x00000020			// Buffer Length
	.word	0x00000000			// Request
	.word	0x00010002			// RPI_FIRMWARE_GET_BOARD_REVISION
	.word	0x00000004			// Data Length
	.word	0x00000000			// Request
	.globl BoardRevision
BoardRevision:
	.word	0x00000000			// Revision ID
	.word	0x00000000			// Data End
	.word	0x00000000			// NULL
