# Introduction

Code for [Adaptive response to BET inhibition induces therapeutic vulnerability to MCL1 inhibitors in breast cancer](https://www.biorxiv.org/content/10.1101/711895v1) using TargetScore algorithm. Reproduced Target Score calculated for paper for figure 2 C. Reproduce Volcano plots for figure 2 D&E.

# Files

* example_hcc1954.txt: Input drug perturbation data for HCC1954 cell line. With columns as antibody, rows as samples.
* fs.txt: Functional scores used for each antibody screened. +1 as oncoprotein, -1 as tumor suppressors, 0 as functions unknown or acting both as oncoprotein and tumor suppressor. NOTE: Used for all cell lines.
* ts_mcl1.R: Code for analyzing drug perturbation data using target score package.
