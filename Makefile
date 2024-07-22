## This is drive_loading (part of Chyun's youtube awareness)

current: target
-include target.mk

# -include makestuff/perl.def

vim_session:
	bash -cl "vmt"

######################################################################

Sources += Makefile README.md

Sources += $(wildcard *.R)
Sources += $(wildcard *.tsv)

######################################################################

## Rebuilding 2021 May 06 (Thu)

Sources += $(wildcard *.py)

## Dropboxed version not tested
## 2021 Jan 02 (Sat) drive_loading.py has disappeared! Ask Matt
drive_files:
	cd .. && $(MAKE) csv_files
	ln -s ../csv_files $@
drive_files/update: drive_loading.py
	$(MAKE) drive_files
	python3 $<
	touch $@

## Mystery! works for MS but not for JD
aggregated_data.csv: aggregation.py $(wildcard drive_files/*.csv) code_source.tsv codes_prevention.tsv codes_theme.tsv
	python3 $<
 
######################################################################

## Combine files into a data frame, select main theme and date
theme_date.Rout: theme_date.R drive_files $(sort $(wildcard drive_files/2*.csv))
	$(makeR)

theme_code.Rout.csv:
theme_code.Rout: theme_code.R theme_date.rda codes.tsv
	$(makeR)

Ignore += requirements.out
Sources += requirements.txt
requirements.out: requirements.txt
	pip3 install -r $< > $@

Ignore += $(wildcard *.pickle)

######################################################################

## MOVING to lab repo
theme_count.Rout: theme_count.R theme_date.rda
	$(makeR)

theme_density.Rout: theme_density.R theme_count.rda
	$(makeR)

######################################################################

## Current gigantic Matt script 2021 Feb 03 (Wed)

visualization.Rout: visualization.R
	$(pipeR)

######################################################################

## Trying to recode, but confused now

## What is Matt doing?

sources.Rout: sources.R
	$(pipeR)

######################################################################

### Makestuff

Ignore += makestuff
msrepo = https://github.com/dushoff

## Want to chain and make makestuff if it doesn't exist
## Compress this ¶ to choose default makestuff route
Makefile: makestuff/Makefile
makestuff/Makefile:
	cd .. && $(MAKE) makestuff
	ln -s ../makestuff .
	ls makestuff/Makefile

-include makestuff/os.mk

-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
