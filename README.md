Mooshimeter Runtime Log Processor v1.0

Original code (c) Mechtron Systems 2017 and was created with Lazarus/fpc by marko 
This means you can compile on Linux, Windows or Mac - WOW!

This program reads a number of Mooshimeter log files, 
analyses the voltage data looking for major changes potentially indicating 
change of state such as on and off.

A typical application example would be using a current transformer on a 
power cable to determine electric motor run times.

Basic Operation:
1. Load Mooshimeter Files
2. Analyse
3. Determine on and off cutoff limits from the histogram.  Bins & Clip can help.
4. Process data
5. Save state .csv file 

Source code on github: https://github.com/mechtronsystems/mooshiruntimelog


