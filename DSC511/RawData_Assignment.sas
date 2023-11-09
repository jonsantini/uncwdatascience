/* PROMPT */
/* Complete the wrap-up activity at the end of Chapter 3 by writing code to read the  */
/* Ipums2010Dirtied.dat file and validate it against the SAS (.sas7bdat) file IPUMS2010Basic.  */
/* Then use the file you read to make output tables/graphs shown in section 3.2. */


filename SASDataa '/home/u63548322/my_shared_file_links/blumj/BookData/';


/* DIRTY */
data dirty (drop=MortPayChar MortgageStatuu);
	infile SASDataa('SomeRawData/IPUMS2010Dirtied.dat') dlm='09'x dsd missover;
	input Serial CityPop:comma. Metro CountyFips Ownership:$6. MortgageStatuu:$45. HHIncome:comma. 
  		HomeValue:comma. City:$43. State:$57. MortPayChar:$30.; 
  	format HHIncome HomeValue MortgagePayment dollar16. Metro best12.;
  	label Serial = 'Household serial number' 
  		CountyFips = 'County (FIPS code)'
  		Metro = 'Metropolitan status'
  		CityPop = 'City population'
  		HHIncome = 'Total household income'
  		HomeValue = 'House value'
  		MortgagePayment = 'First mortgage monthly payment';
  	 
  	 Ownership = propcase(ownership);
  	 
  	 State = propcase(State);
  	 
  	 if find(MortgageStatuu,'deed') then 
     	MortgageStatuu = catx(' ',MortgageStatuu,'debt');
  	 
  	 MortgageStatuu = tranwrd(MortgageStatuu,':','/');
      
     if find(MortgageStatuu,'N/A/') then 
     	MortgageStatuu = compress(MortgageStatuu, '/');
     	
     if find(MortgageStatuu,'N.A.') then 
     	MortgageStatuu = compress(MortgageStatuu,'.');
     	
     MortgageStatus = MortgageStatuu;
     if find(MortgageStatus, 'NA') then
     	MortgageStatus = 'N/A';
     	
     City = tranwrd(City,'-',', ');
     
     if find(State,'District Of ') then 
     substr(State, 1) = 'District of Columbia';
     
     MortPayChar = tranwrd(MortPayChar,'l','1'); 
     
	 MortgagePayment = abs(input(MortPayChar,dollar16.));
	 
	 if find(City,'Augusta') then 
     substr(City, 1) = 'Augusta-Richmond County, GA';
     
     if find(City,'Lexington, ') then 
     substr(City, 1) = 'Lexington-Fayette, KY';
     
     if find(City,'Winston, ') then 
     substr(City, 1) = 'Winston-Salem, NC';
	 
	 if find(City,'Nashville, ') then 
     substr(City, 1) = 'Nashville-Davidson, TN';
run;


/* CLEAN */
data clean;
	retain Serial CityPop Metro CountyFips Ownership MortgageStatus HHIncome
  		HomeValue City State MortgagePayment;
	set '/home/u63548322/my_shared_file_links/blumj/BookData/SASData/ipums2010basic.sas7bdat';
	format HHIncome HomeValue MortgagePayment dollar16.;
run;


/* COMPARE */
proc compare base=dirty compare=clean
	out=differences outall outnoequal;
run;


/* TABLES */
/* Output 3.2.1 */
title 'Output 3.2.1: Listing of Ownership Categories and Frequencies';
ods noproctitle;
proc freq data=dirty;
	table Ownership;
run;


/* Output 3.2.2 */
title 'Output 3.2.2: Listing of Mortgage Status Categories and Frequencies';
ods noproctitle;
proc freq data=dirty;
	table MortgageStatus;
run;


/* Output 3.2.3 */
title 'Output 3.2.3: Listing of Cities';
ods noproctitle;
proc freq data=dirty;
	table City;
run;


/* Output 3.2.4 */
title 'Output 3.2.4: Listing of State Names';
ods noproctitle;
proc freq data=dirty;
	table State;
run;


/* Output 3.2.5 */
title 'Output 3.2.3: Quantiles on Mortgage Payments';
ods noproctitle;
proc means data=dirty n nmiss min p25 p50 p75 max maxdec=1 nonobs;
	var MortgagePayment;
	label MortgagePayment = ;
run;


/* Output 3.2.6 */
title 'Output 3.2.3: Quantiles on Mortgage Payments';
ods noproctitle;
proc means data=dirty n p50 p60 p70 p75 p80 p90 p95 p99 max maxdec=1 nonobs;
	var MortgagePayment;
	label MortgagePayment = ;
run;

/* GRAPHS */
/* 3.2.7 */
proc format;
	value Mort
		0 = "None"
		1-350 = "$350 and Below"
		351-1000 = "$351 to $1000"
		1001-1600 = "$1001 to $1600"
		1601-high = "Over $1600"
		;
run;

title 'Output 3.2.7: Charting Mortgage Payments Versus Metro Status';
ods graphics on; 
proc sgplot data=dirty;
	hbar MortgagePayment/group=metro;
	format MortgagePayment Mort.;
run;




/* 3.2.8 */
proc format;
	value Mort
		0 = "None"
		1-350 = "$350 and Below"
		351-1000 = "$351 to $1000"
		1001-1600 = "$1001 to $1600"
		1601-high = "Over $1600"
		;
run;

ods select none;
ods output OneWayFreqs=Freqs;
proc freq  data=dirty;
	table MortgagePayment;
	format MortgagePayment Mort.;
run;

title 'Output 3.2.8: Cumulative Distribution of Mortgage Payments';
ods select all;
proc sgplot data=Freqs noborder;
	vbar MortgagePayment / response=CumPercent barwidth=1;
	xaxis label='Mortgage Payment';
	yaxis label='Cumulative Percentage' offsetmax=0;
run;




/* 3.2.9 */
proc format;
 	value income
 		low-<0='Negative'
 		0-45000='$0 to $45K'
 		45001-90000='$45K to $90K'
 		90001-high='Above $90K'
 		;
 		
 	value Mort
		0 = "None"
		1-350 = "$350 and Below"
		351-1000 = "$351 to $1000"
		1001-1600 = "$1001 to $1600"
		1601-high = "Over $1600"
		;
run;

ods select none;
ods output CrossTabFreqs=TwoFreaky;
proc freq data=dirty;
 	table HHIncome*MortgagePayment;
 	format HHIncome income. MortgagePayment Mort.;
 	where MortgagePayment gt 0 and HHIncome ge 0;
run;

ods select all;
title 'Output 3.2.9: Household Income Levels and Mortgage Payments';
proc sgplot data=TwoFreaky;
 	hbar HHIncome / response=RowPercent group=MortgagePayment groupdisplay=cluster;
 	xaxis label='Percent within Income Class' grid gridattrs=(color=gray66) 
 		values=(0 to 65 by 5) offsetmax=0;
 	yaxis label='Household Income';
 	keylegend / position=top title='Mortgage Payment' down=2;
 	where HHIncome is not missing and MortgagePayment is not missing;
run;










