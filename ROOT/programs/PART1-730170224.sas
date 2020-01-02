/*********************************************************************
Project				: BIOS 511 Course - Final pt 1

Program name 		: PART1-730170224.sas

Author				: Eileen Yang

Date created		: 2019-12-03

Purpose				: Creates the ADSIS dataset from the SIS16 csv file.

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
SAS Code for Part # 1
 *********************************************************************/
/*******importing the csv file to be used to create adsis dataset******/
FILENAME REFFILE "&qdataPath./SIS16.csv";

PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=WORK.sis16;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=sis16;
RUN;

proc print data=sis16 (obs=30);
run;

/********temporarily getting rid of the labels for q1-q16*******/
data sis16edit;
	set sis16;
	array Q(16) Q1-Q16;

	do j=1 to 16;

		if length(Q[j])>1 then
			delete;

		if length(Q[j]) le 1 then
			output;
	end;
	drop j;
run;

/********converting everything relevant into numeric variables******/
proc sort data=sis16edit out=sis16sort;
	by responseid;
run;

data sis16sortedit;
	set sis16sort;
	by responseid;

	if first.responseid;
run;

data sis16num;
	set sis16sortedit;
	usubjid=input(responseid, 8.);
	nq1=input(q1, 8.);
	nq2=input(q2, 8.);
	nq3=input(q3, 8.);
	nq4=input(q4, 8.);
	nq5=input(q5, 8.);
	nq6=input(q6, 8.);
	nq7=input(q7, 8.);
	nq8=input(q8, 8.);
	nq9=input(q9, 8.);
	nq10=input(q10, 8.);
	nq11=input(q11, 8.);
	nq12=input(q12, 8.);
	nq13=input(q13, 8.);
	nq14=input(q14, 8.);
	nq15=input(q15, 8.);
	nq16=input(q16, 8.);
	drop q1-q16 responseid;
run;

proc sort data=sis16num out=sis16sort2;
	by usubjid;
run;

/*****************BEGIN CREATING ADSIS*****************/
/*****usubjid zero padding, labeling q1-q16 to the corresponding survey questions*****/
data adsis1;
	set sis16sort2;
	usubjidnew=put(usubjid, z4.);
	drop usubjid;
	rename usubjidnew=usubjid;
	
	sumvar=.;
	
	label nq1="In the past 2 weeks, how difficult was it to dress the top part of your body?" 
		nq2="In the past 2 weeks, how difficult was it to bathe yourself?" 
		nq3="In the past 2 weeks, how difficult was it to get to the toilet on time?" 
		nq4="In the past 2 weeks, how difficult was it to control your bladder (not have an accident)?" nq5="In the past 2 weeks, how difficult was it to control your bowels (not have an accident)?" 
		nq6="In the past 2 weeks, how difficult was it to stand without losing balance?" 
		nq7="In the past 2 weeks, how difficult was it to go shopping?" 
		nq8="In the past 2 weeks, how difficult was it to do heavy household chores (e.g. vacuum, laundry or yard work)?" 
		nq9="In the past 2 weeks, how difficult was it to stay sitting without losing your balance?" 
		nq10="In the past 2 weeks, how difficult was it to walk without losing your balance?" 
		nq11="In the past 2 weeks, how difficult was it to move from a bed to a chair?" 
		nq12="In the past 2 weeks, how difficult was it to walk fast?" 
		nq13="In the past 2 weeks, how difficult was it to climb one flight of stairs?" 
		nq14="In the past 2 weeks, how difficult was it to walk one block?" 
		nq15="In the past 2 weeks, how difficult was it to get in and out of a car?" 
		nq16="In the past 2 weeks, how difficult was it to carry heavy objects (e.g. bag of groceries) with your affected hand?" 
		sumvar="Stroke Impact Scale 16 Score";
run;

/**************calculating SIS-16 score, temporarily named sumvar for aval later************/
data adsis2;
	set adsis1;
	
	nmiss=cmiss(of nq1--nq16);
	max_raw=5*(16-nmiss);
	min_raw=1*(16-nmiss);
	raw_score=sum(of nq1-nq16);

	if nmiss le 4 then
		sumvar=round((raw_score-min_raw)/(max_raw-min_raw)*100,0.01);
	else if nmiss >4 then
		sumvar=.;
run;

/************transposing dataset by usubjid**************/
proc transpose data=adsis2 out=adsis2trans;
	by usubjid nmiss;
	var nq1-nq16 sumvar;
run;

/************creating qstest, aval, qstestcd, qsseq************/
data adsis3;
	set adsis2trans;
	by usubjid;
	rename _label_=qstest col1=aval;
	length qstestcd $10.;

	if first.usubjid then qsseq=0;
		qsseq+1;
	
	qstestcd=cats("ITEM", put(qsseq, z2.));
	if qstestcd="ITEM17" then
		qstestcd="SIS16";
	
	if qstestcd="SIS16" then
		qstyp="DERIVED";
	else if qstestcd ne "SIS16" then
		qstyp=" ";
run;

/***********creating avalc**********/
data adsis4;
	length avalc $20.;
	set adsis3;

	if aval=1 and qstyp=" " then
		avalc="Could not do at all";
	else if aval=2 and qstyp=" " then
		avalc="Very difficult";
	else if aval=3 and qstyp=" " then
		avalc="Somewhat difficult";
	else if aval=4 and qstyp=" " then
		avalc="A little difficult";
	else if aval=5 and qstyp=" " then
		avalc="Not difficult at all";
	else if aval=. then
		avalc=" ";
	else if qstyp="DERIVED" then
		avalc=put(aval, 12.2);
		
	avalc2=strip(avalc);
	drop avalc;
	rename avalc2=avalc;
run;

/************creating qsstat***********/
data adsis5;
	length qsstat $50.;
	set adsis4;

	if aval ge 0 and qstyp="DERIVED" then
		qsstat=" ";

	if aval <0 and qstyp="DERIVED" then
		qsstat="NOT CALCULATED";
run;

/************creating qsreasnd**********/
data adsis6;
	set adsis5;

	if not missing(qsstat) and 16-nmiss le 12 then
		qsreasnd="Only "||strip(put(16-nmiss, 3.))||" Items Answered";
run;

/**********tidying up the overall adsis dataset with correct labels and lengths and dropping irrelevant vars**********/
data adsis;
	length usubjid $4. qsseq 8. qstestcd $10. qstest $200. qstyp $10. avalc $20. 
		aval 8. qsstat $50. qsreasnd $50.;
	retain usubjid qsseq qstestcd qstest qstyp avalc aval qsstat qsreasnd;
	set adsis6;
	drop nmiss _name_;
	label usubjid="Unique Subject ID" qsseq="Item Sequence Number" 
		qstestcd="Survey Item Code" qstest="Survey Item" qstyp="Survey Item Type" 
		avalc="Analysis Value (Character)" aval="Analysis Value" 
		qsstat="SIS-16 Score Status" qsreasnd="Reason SIS-16 Score Not Calculated";
run;

/*******check contents of adsis********/
proc contents data=adsis order=varnum;
run;

data adata.adsis;
	set adsis;
run;
