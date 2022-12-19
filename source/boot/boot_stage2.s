/*_____________________________________________________________________________
 │                                                                            |
 │ COPYRIGHT (C) 2022 Mihai Baneu                                             |
 │                                                                            |
 | Permission is hereby  granted,  free of charge,  to any person obtaining a |
 | copy of this software and associated documentation files (the "Software"), |
 | to deal in the Software without restriction,  including without limitation |
 | the rights to  use, copy, modify, merge, publish, distribute,  sublicense, |
 | and/or sell copies  of  the Software, and to permit  persons to  whom  the |
 | Software is furnished to do so, subject to the following conditions:       |
 |                                                                            |
 | The above  copyright notice  and this permission notice  shall be included |
 | in all copies or substantial portions of the Software.                     |
 |                                                                            |
 | THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS |
 | OR   IMPLIED,   INCLUDING   BUT   NOT   LIMITED   TO   THE  WARRANTIES  OF |
 | MERCHANTABILITY,  FITNESS FOR  A  PARTICULAR  PURPOSE AND NONINFRINGEMENT. |
 | IN NO  EVENT SHALL  THE AUTHORS  OR  COPYRIGHT  HOLDERS  BE LIABLE FOR ANY |
 | CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT |
 | OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  |
 | THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                 |
 |____________________________________________________________________________|
 |                                                                            |
 |  Author: Mihai Baneu                           Last modified: 18.Dec.2022  |
 |                                                                            |
 |___________________________________________________________________________*/


#define DELAY         1000000
#define RESET_BASE    0x4000C000
#define RESET_CLR     0x4000F000
#define GPIO0_CTRL    0x400140cc
#define SIO_BASE      0xd0000000
#define GPIO_OE_SET   0x24
#define GPIO_OUT_SET  0x14
#define GPIO_OUT_CLR  0x18

.syntax unified
.global _stage2_boot
.global _entry_point

/*-----------------------------------------------------------*/
/*                        _stage2_boot                       */
/*-----------------------------------------------------------*/
.section .text
.type _stage2_boot,%function
.thumb_func
_stage2_boot:
    /* force debug breakpoint */
    bkpt 

    /* enable GPIO periferal */
    movs r0, #32
    ldr  r1, =#RESET_CLR
    str  r0, [r1]

wait_for_reset:
    ldr  r1, =#RESET_BASE
    ldr  r3, [r1, #8]
    tst  r0, r3
    beq  wait_for_reset

    /* configure GPIO periferal */
    movs r0, #5
    ldr  r1, =#GPIO0_CTRL
    str  r0, [r1]

    movs r3, #1
	lsls r3, r3, #25
    ldr  r4, =#SIO_BASE
    str  r3, [r4, #GPIO_OE_SET]

    /* blink */
    ldr  r1, =#DELAY

led_on:
    str  r3, [r4, #GPIO_OUT_SET]
    movs r0, #0
led_on_loop:
    adds r0, r0, #1
    cmp r0, r1
    beq led_off
    b led_on_loop

led_off:
    str  r3, [r4, #GPIO_OUT_CLR]
    movs r0, #0
led_off_loop:
    adds r0, r0, #1
    cmp r0, r1
    beq led_on
    b led_off_loop

.size _stage2_boot, .-_stage2_boot
