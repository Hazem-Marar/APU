<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The design contain the Sbox used in AES encryption and it's inverse. The Sbox and the inverse Sbox are implemented as LUT and using composite field arithmetic

## How to test

Two mode bits will specify the block to enable. Mode =0: Composite Sbox, Mode=1: Composite inverse Sbox, Mode=2: LUT Sbox, Mode=3: inverse LUT Sbox

## External hardware

No need for external hardware. The output can be connected to LEDs to validate
