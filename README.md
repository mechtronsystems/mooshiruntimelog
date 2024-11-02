Mooshimeter Runtime Log Processor v2.0

Original code (c) Mechtron Systems 2017-2023 and was created with Lazarus/fpc by marko.

This means you can compile on Linux, Windows or Mac - WOW!

Original source code on github: https://github.com/mechtronsystems/mooshiruntimelog

You may add to, or change this software as required but the original contents 
of this file above this line must remain preserved and you must distribute this 
notice with any software distributed in any form.  This software is licensed under MPL ver 2.0

This program reads a number of Mooshimeter log files and analyses the voltage and current
data looking for major changes potentially indicating change of state such as on and off.

A typical application example would be using a current transformer on a 
power cable to determine electric motor run times.

Basic Operation:
1. Load Mooshimeter Files
2. Analyse
3. Determine on and off cutoff limits from the histogram.  Bins & Clip can help.
4. Process data
5. Save state .csv file 



