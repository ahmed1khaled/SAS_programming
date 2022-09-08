
libname tsa "/home/u62064965/EPG1v2/data";
options validvarname=v7;

ods pdf file="/home/u62064965/EPG1v2/output/results1.pdf" startpage=no style=journal 
	pdftoc=1;
	
proc import datafile="/home/u62064965/EPG1v2/data/TSAClaims2002_2017.csv" 
		dbms=csv out=tsa.ClaimsImport replace;
	guessingrows=max;
run;

data dat;
	set tsa.ClaimsImport;

	if Claim_Type in ('-', "") then
		Claim_Type="Unknown";

	if Claim_Site in ('-', "") then
		Claim_Site="Unknown";

	if Disposition in ('-', "") then
		Disposition="Unknown";
	*if Airport_Code in ('-',"") then 
		Airport_Code=mod(Airport_Code);
	*if Airport_Name in ('-',"") then 
		Airport_Name=mod(Airport_Name);
	*if StateName in ('-',"") then 
		StateName=mod(StateName);
	StateName=propcase(StateName);
	State=upcase(State);

	if (Incident_Date=. or Date_Received=. or year(Incident_Date)<2002 or 
		year(Incident_Date)>2017 or year(Date_Received)<2002 or 
		year(Date_Received)>2017 or Incident_Date > Date_Received) then
			Date_issues="Need_review";
	format Date_Received date9. Incident_Date date9. Close_Amount Dollar20.2;
	drop County City run;
	title "data after preparing";

proc print data=dat (obs=10);
run;

proc sort data=dat out=claims_clear nodupkey dupout=claims_not_clear;
	by _all_;
run;

proc sort data=claims_clear;
	by Incident_Date;
run;

title "Data sorted by Incident_Date and removed duplicated";

proc print data=claims_clear (obs=40);
run;

title " Date Issues in the Data";

proc freq data=claims_clear;
	table Date_Issues / nocum nopercent;
run;

title "freq table by Incident_Date  ";

proc freq data=claims_clear;
	table Incident_Date / nocum nopercent;
	format Incident_Date monname.;
run;

ods graphics on;
title "visulize Claims by Year";

proc freq data=claims_clear;
	table Incident_Date / nocum nopercent plots=freqplot;
	format Incident_Date year4.;
run;

title;
title "freq table by Date_Received  ";

proc freq data=claims_clear;
	table Date_Received / nocum nopercent;
	format Date_Received monname.;
run;

proc freq data=claims_clear;
	table Date_Received / nocum nopercent plots=freqplot;
	format Date_Received year4.;
run;


title "freq table by Claim_Type ";

proc freq data=claims_clear;
	table Claim_Type / nocum nopercent;
run;

title "freq table by Claim_Site ";

proc freq data=claims_clear;
	table Claim_Site / nocum nopercent;
run;

title "freq table by Disposition ";

proc freq data=claims_clear;
	table Disposition / nocum nopercent;
run;


title "mean table by Close_Amount";

proc means data=claims_clear mean min max sum;
	var Close_Amount;
run;

title "freq table by Airport_Name";
proc freq data=claims_clear;
	table Airport_Name / nocum nopercent;
run;
title;
title "freq table by Claim_Type";
proc freq data=claims_clear;
	table Claim_Type / nocum nopercent;
run;
title;
title "freq table by Claim_Site";
proc freq data=claims_clear;
	table Claim_Site / nocum nopercent;
run;
title;

proc contents data=claims_clear;
run;
ods pdf close;