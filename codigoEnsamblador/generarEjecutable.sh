#!/bin/bash
for file in *.asm
    do
        as6809 -o $file
    done

aslink -s -m -w -u main.s19 *.rel

rm *.rel