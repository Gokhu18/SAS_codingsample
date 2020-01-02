/*********************************************************************
Project				: BIOS 511 Course - Final Pt 2

Program name 		: PART2-730170224.sas

Author				: Eileen Yang

Date created		: 2019-12-03

Purpose				: Final Part 2 - creating histogram and boxplot for 
					  SIS-16 values and printing to one pdf file named 
					  PART2-730170224.pdf.

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
SAS Code for Part # 2
 *********************************************************************/
data adsis_plot;
	set adata.adsis;
	by usubjid;
	if last.usubjid;
run;

ods pdf file="&outPath./PART2-730170224.pdf" startpage=no;

ods select sgplot;
ods graphics / height=4in width=6in border=off;
title "Distribution of SIS-16 Scores";
proc sgplot data=adsis_plot;
	histogram aval / fillattrs=(color=lightred) 
					dataskin=crisp scale=proportion;
	label aval = " ";
	xaxis label= " ";
	yaxis grid;
run;

ods select sgplot;
ods graphics / height=4in width=6in border=off;
title " ";
proc sgplot data=adsis_plot;
	hbox aval / dataskin=crisp 
				fillattrs=(color=lightred) 
				whiskerattrs=(pattern=dash) meanattrs=(symbol=circlefilled)
				outlierattrs=(symbol=x);
	label aval = " ";
	xaxis label= " " grid;
run;

ods pdf close;



