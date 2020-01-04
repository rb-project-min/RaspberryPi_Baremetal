	.section ".text"
	.global _start
	.balign 0x4000
	.arm
_start:
// ================================================================
//  0x0000�Ƀ��[�h�����ꍇ�̊��荞�݃G���A 0x0000�ɃR�s�[����
//  �R�s�[��͐�΃A�h���X�ŃA�N�Z�X���邽��
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
	sub		r11, r11, #0x8000		// �u�[�g�A�h���X�Ǝ��A�h���X�̃I�t�Z�b�g
	str		r11, RPi_BootOffset		// �u�[�g�I�t�Z�b�g�̕ۑ�

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
//  rpi.h�ɂ�STACK_SIZE���`���Ă���ꍇ�͂��̒l��D��
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
1:	b		main							// main�֐��փW�����v
hang:
	b		.								// �������[�v

RPi_BootOffset:
	.word	0x00000000			// �u�[�g�A�h���X�Ǝ��A�h���X�̃I�t�Z�b�g

	.globl RPi_IO_Base_Addr
RPi_IO_Base_Addr:				// Peripheral Base Addr
	.word	0x20000000

	.globl RPi_LocalPeripheralsAddr
RPi_LocalPeripheralsAddr:		// Local Peripherals Addr
	.word	0x40000000
