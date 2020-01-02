/*********************************************************************
Project				: BIOS 511 Course - Final Pt 3

Program name 		: PART3-730170224.sas

Author				: Eileen Yang

Date created		: 2019-12-03

Purpose				: Final Part 3 - calling the freq macro created in 
					  "PART3-730170224.sas" to perform frequency analyses 
					  on aval for the different survey items 
					  in ADSIS dataset.

Revision history	:

Date			Author		Ref(#)		Revision

searchable reference phrase: *** [#] ***;
 *********************************************************************/
option mergenoby=error nodate nonumber;
ods noproctitle;
%let root		= /folders/myshortcuts/MyFolders/BIOS511/ROOT;
%let qdataPath	= &root/qualtrics_data;
%let adataPath	= &root/analysis_data;
%let outPath	= &root/output;
%let macroPath	= &root/macros;

libname adata "&adataPath.";
/*********************************************************************
SAS Code for Part # 3
 *********************************************************************/
ods pdf file="&outPath./PART3-730170224.pdf";
proc format;
	value fmtA
 		1-3 = 'At Least Somewhat Difficult'
 		4	= 'A Little Difficult'
 		5	= 'No Difficulty';
run;

%include "&macroPath./PART3-FREQ-730170224.sas";

%freq(cd=ITEM01, fmt=FMTA);
%freq(cd=ITEM02, fmt=NONE);

ods pdf close;
