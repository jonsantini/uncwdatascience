/* Reproduce Outputs 2.2.1 - 2.2.4 */
/* Reproduce Outputs 3.2.7 - 3.2.9 */

libname SASDta '/home/u63548322/my_shared_file_links/blumj/BookData/SASData';

/* 2.2.1 */ 
proc format;
	value MetroA
		0 = "Not Identifiable"
		1 = "Not in Metro Area"
		2 = "Metro, Inside City"
		3 = "Metro, Outside City"
		4 = "Metro, City Status Unknown"
		;
run;

ods noproctitle;
proc means data=SASDta.ipums2010basic n mean median stddev min max maxdec=1 nonobs;
	class Metro;
	var MortgagePayment;
	where MortgagePayment >= 100;
	format Metro MetroA.;
	label MortgagePayment = 'Mortgage Payment';
run;



/* 2.2.2 */
proc format;
	value MetroA
		0 = "Not Identifiable"
		1 = "Not in Metro Area"
		2 = "Metro, Inside City"
		3 = "Metro, Outside City"
		4 = "Metro, City Status Unknown"
		;

	value HHIncome
		low-<0 = "Negative"
		0-45000 = "$0 to $45k"
		45001-90000 = "$45k to $90k"
		90001-high = "Above $90k"	
		;
run;

ods noproctitle;
proc means data=SASDta.ipums2010basic min median max maxdec=0 nonobs;
	class Metro HHIncome;
	var MortgagePayment HomeValue;
	format Metro MetroA. HHIncome HHIncome.;
	where (Metro between 2 and 4) and (MortgagePayment >= 100);
	label MortgagePayment = 'Mortgage Payment' HomeValue = 'Home Value' HHIncome = 'Household Income' 
		Metro = 'Metro';
run;




/* 2.2.3 */
proc format;
	value Mort
		0 = "None"
		1-350 = "$350 and Below"
		351-1000 = "$351 to $1000"
		1001-1600 = "$1001 to $1600"
		1600-high = "Over $1600"
		;

	value HHIncome
		low-<0 = "Negative"
		0-45000 = "$0 to $45k"
		45001-90000 = "$45k to $90k"
		90001-high = "Above $90k"	
		;
run;

ods noproctitle;
proc freq data=SASDta.ipums2010basic;
	table HHIncome*MortgagePayment / nocol nopercent;
	format HHIncome HHIncome. MortgagePayment Mort.;
	label HHIncome='Household Income' MortgagePayment='Mortgage Payment';
	where MortgagePayment >= 100;
run;





/* 2.2.4 */
proc format;
	value Mort
		0 = "None"
		1-350 = "$350 and Below"
		351-1000 = "$351 to $1000"
		1001-1600 = "$1001 to $1600"
		1601-high = "Over $1600"
		;

	value HHIncome
		low-<0 = "Negative"
		0-45000 = "$0 to $45k"
		45001-90000 = "$45k to $90k"
		90001-high = "Above $90k"	
		;
		
	value MetroA
		0 = "Not Identifiable"
		1 = "Not in Metro Area"
		2 = "Metro, Inside City"
		3 = "Metro, Outside City"
		4 = "Metro, City Status Unknown"
		;
run;

ods noproctitle;
proc freq data='/home/u63548322/my_shared_file_links/blumj/BookData/SASData/ipums2010basic.sas7bdat';
	table Metro*HHIncome*MortgagePayment / nocol nopercent;
	format HHIncome HHIncome. MortgagePayment Mort. Metro MetroA.;
	label HHIncome='Household Income' MortgagePayment='Mortgage Payment';
	where (Metro between 2 and 4) and (MortgagePayment >= 100);
run;




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

ods graphics on; 
proc sgplot data='/home/u63548322/my_shared_file_links/blumj/BookData/SASData/ipums2010basic.sas7bdat';
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
proc freq  data=SASDta.ipums2010basic;
	table MortgagePayment;
	format MortgagePayment Mort.;
run;

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
proc freq data=SASDta.ipums2010basic;
 	table HHIncome*MortgagePayment;
 	format HHIncome income. MortgagePayment Mort.;
 	where MortgagePayment gt 0 and HHIncome ge 0;
run;

ods select all;
proc sgplot data=TwoFreaky;
 	hbar HHIncome / response=RowPercent group=MortgagePayment groupdisplay=cluster;
 	xaxis label='Percent within Income Class' grid gridattrs=(color=gray66) 
 		values=(0 to 65 by 5) offsetmax=0;
 	yaxis label='Household Income';
 	keylegend / position=top title='Mortgage Payment' down=2;
 	where HHIncome is not missing and MortgagePayment is not missing;
run;




