/*********************************************************************
Project				: BIOS 511 Course - Final Pt 3 Macro(Freq)

Program name 		: PART3-FREQ-730170224.sas

Author				: Eileen Yang

Date created		: 2019-12-03

Purpose				: This macro performs frequency analyses on the Analysis
						Value (aval) for specified items of the survey questions
						present in the ADSIS dataset. The macro variables
						are CD (possible values: ITEM1-ITEM16)
						and FMT (possible values: FMTA and NONE).
						CD specifies which survey item's avals to focus the
						frequency analysis on, and FMTA specifies whether or not
						to use a previously created format called FMTA.
Revision history	:

Date			Author		Ref(#)		Revision

searchable reference phrase: *** [#] ***;
 *********************************************************************/
%macro freq(cd=BLANK, fmt=BLANK);
	%if &cd ne ITEM01 and &cd ne ITEM02 and &cd ne ITEM03 and &cd ne ITEM03 
		and &cd ne ITEM04 and &cd ne ITEM05 and &cd ne ITEM06 and &cd ne ITEM07 
		and &cd ne ITEM08 and &cd ne ITEM09 and &cd ne ITEM10 and &cd ne ITEM11 
		and &cd ne ITEM12 and &cd ne ITEM13 and &cd ne ITEM14 and &cd ne ITEM15 
		and &cd ne ITEM16| &fmt ne FMTA and &fmt ne NONE %then
			%do;

			%if &cd ne ITEM01 and &cd ne ITEM02 and &cd ne ITEM03 and &cd ne ITEM03 
				and &cd ne ITEM04 and &cd ne ITEM05 and &cd ne ITEM06 and &cd ne ITEM07 
				and &cd ne ITEM08 and &cd ne ITEM09 and &cd ne ITEM10 and &cd ne ITEM11 
				and &cd ne ITEM12 and &cd ne ITEM13 and &cd ne ITEM14 and &cd ne ITEM15 
				and &cd ne ITEM16 %then
					%put &cd is invalid choice for the CD macro variable;

			%if &fmt ne FMTA and &fmt ne NONE %then
				%put &fmt is invalid choice for the fmt macro variable;
			%abort;
		%end;
		
	data adsis_freq;
		set adata.adsis;
		where qstestcd="&cd.";
		call symput("title2",qstest);
	run;


	%if %substr(&cd,5,2) > 09 %then %do;
		title1 "Frequency Analysis of Survey Item %substr(&cd, 5, 2)";
	%end;
	
	%else %if %substr(&cd,5,2) <= 09 %then %do;
		title1 "Frequency Analysis of Survey Item %substr(&cd, 6, 1)";
	%end;
	
	
	title2 "&title2.";

	%if &fmt.=FMTA %then
		%do;

			proc freq data=adsis_freq noprint;
				format aval fmtA.;
				table aval / nocol nocum out=freqprint;
			run;

		%end;
		
	%else %if &fmt.=NONE %then
		%do;

			proc freq data=adsis_freq noprint;
				table aval / nocum nocol out=freqprint;
			run;

		%end;
	
	proc print data=freqprint label noobs;
		label count = "Frequency Count" 
			  percent = "Percent of Total Frequency";
	run;
%mend freq;