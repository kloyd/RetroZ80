* Threaded Interpretive Languages
- by R.G. Loeliger
- ISBN 0-07-038360-X

This is my attempt to implement the TIL described in the above book. The Author uses the Z80 CPU to implement his TIL and I will follow suit. There are several Z80 based single board computers and emulators available now which will make it easy to test.

Assembler syntax should be generic enough to allow any Z80 assembler to build the TIL.

What is a TIL? The easiest answer is to look at FORTH. FORTH is built as an example of a TIL. Stack based, with a set of primitive 'words' e.g. machine code plus the ability to define words in terms of other words, building a dictionary.
It has been said that the process of creating a FORTH program is the process of defining words.


