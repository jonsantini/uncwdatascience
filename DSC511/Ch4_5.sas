/* Setup */
libname BookData "/home/u63548322/my_shared_file_links/blumj/BookData/SASData";
libname RawData '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/';

/*  */
/*  */
/*  */
/* CHAPTER 4 */
/* SETUP */
data IPUMS51015Basic (drop=SerialID MetroCat);
  	set BookData.Ipums2005basic (in=In2005)
  		bookdata.ipums2010basic (in=In2010)
      	bookdata.ipums2015basic(in=In2015 rename=(income=hhincome Population=CityPop));
  	if In2015 then do;
    	Serial = input(serialID,best.);
    	Metro = input(MetroCat,best.);
  	end;
  	length year $4;
	if (In2005 eq 1) then year=2005;
	if (In2010 eq 1) then year=2010;
	if (In2015 eq 1) then year=2015;
run;

/* proc contents data=ipums51015basic; */
/* 	ods select variables; */
/* run; */


/* Figure 4.2.2 */
title 'Output 4.2.2: Histograms Across Years for Nonzero Mortgage Payments';
proc sgpanel data=IPUMS51015Basic;
  panelby year / columns=3 novarname;
  histogram MortgagePayment /scale=proportion  binstart=250 binwidth=500 fillattrs=(color=cx66CC66);
  colaxis label='Mortgage Payment' fitpolicy=stagger;
  rowaxis valuesformat=percent. display=(nolabel) ;
  where MortgagePayment gt 0;
run;


/* Figure 4.2.3 */
ods graphics / attrpriority=color;
title 'Output 4.2.3: Boxplots Across Years for Nonzero Mortgage Payments';
proc sgplot data=IPUMS51015Basic;
	vbox MortgagePayment / group=year category=year extreme nofill meanattrs=(symbol=circle)
		lineattrs=(thickness=1.5);
	keylegend / title=' ' location=inside position=topright noborder;
	xaxis display=none;
	yaxis display=(nolabel);
	where MortgagePayment gt 0;
run;


/* Figure 4.2.4 */
data ipums424spec;
	set IPUMS51015Basic;
	length Metro2 $3;
	if metro eq 0 OR metro eq 1 then do;
		metro2 = 'No';
	end;
	if metro in (2,3,4) then do;
		metro2 = 'Yes';
	end;
run;

title 'Output 4.2.4: Boxplots Across Years, Separated by Metro Status';
proc sgpanel data=ipums424spec;
	panelby metro2 / columns=2 novarname;
	vbox MortgagePayment / group=year category=year extreme nofill;
	keylegend / title = ' ';
	rowaxis display=(nolabel);
	where MortgagePayment gt 0;
run;


/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */


/* CHAPTER 5 SETUP */
/* 2005 */
data ipums2005Utility;
  infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/Utility Cost 2005.txt' 
  	dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
run;
 
data All2005;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
  year = 2005;
run;


/* 2010 */
data ipums2010Utility;
   infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/Utility Costs 2010.csv' 
      firstobs=5 dsd;
   input Serial:comma. Water:comma. Gas:dollar. Electric:comma.  Fuel:comma.;
   if electric ge 9990 then electric = .;
   if Gas ge 9990 then Gas = .;
   if water ge 9990 then water = .;
   if fuel ge 9990 then fuel = .;
   format electric--fuel dollar10.;
   label Electric='Electricity Cost';
   year=2010;
run;

data All2010;
  merge bookdata.ipums2010basic ipums2010utility;
  by serial;
  if HomeValue eq 9999999 then HomeValue = .;
  if HHIncome eq 9999999 then HHIncome = .;
run;


/* 2015 */ 
data ipums2015Utility (drop=electricity);
   infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/2015 Utility Cost.dat' 
   		firstobs=8;
   input @1 Serial comma8. @9 Water dollar5. @14 Gas dollar5. 
   		@19 Electricity dollar5. @24 Fuel dollar5.;
   if water ge 9990 then water = .;
   if Gas ge 9990 then Gas = .;
   if electricity ge 9990 then electricity = .;
   if fuel ge 9990 then fuel = .;
   electric = electricity;
   format water--fuel dollar10.;
run;

	/* Get new columns: Serial, Metro, HHIncome */
data ipums2015basicB (drop=SerialID MetroCat Income Population);
	set bookdata.ipums2015basic;
	Serial=input(compbl(SerialID),best.);
	Metro = input(MetroCat,best.);
	HHIncome=input(Income,best.);
	Citypop = population;
	Year=2015;
run;

data All2015;
  merge ipums2015basicB ipums2015Utility;
  by serial;
  if HomeValue eq 9999999 then HomeValue = .;
  if HHIncome eq 9999999 then HHIncome = .;
run;

/* Everything for All Years */
data AllAll;
	set All2005 All2010 All2015;
run;


/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */


/* Figure 5.2.2 */ 

/* Means from AllAll */
ods select none;
proc means data=AllAll mean;
	class state year;
	var electric gas;
	where (state='North Carolina' OR state='South Carolina' OR state='Virginia');
  	ods output summary=means;
run;

/* Graph Means from AllAll */
ods select all;
title 'Output 5.2.2: Plot of Mean Electric and Gas Costs';
proc sgplot data=means;
  scatter x=electric_mean y=gas_mean / datalabel=year group=state markerattrs=(symbol=circlefilled);
  keylegend / title='' location=inside position=topright;
  xaxis label='Mean Electric Cost ($)';
  yaxis label='Mean Gas Cost ($)';
run;



/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */


/* Figure 5.2.3 Method 1 */
/* ods select none; */
/* proc report data=AllAll out=medians; */
/*  	column homevalue year state electric gas water fuel; */
/*  	define homevalue / group; */
/* 	define year / group; */
/* 	define state / group; */
/*   	define electric -- fuel / median format = dollar10.2; */
/*   	label Electric = "Electric"; */
/*     label Gas = "Gas"; */
/*     label Water = "Water"; */
/*     label Fuel = "Fuel"; */
/*     where state in ('North Carolina', 'South Carolina'); */
/*     by year; */
/* run; */
/*  */
/* proc transpose data=medians out=medianT(drop=_label_ rename=(col1=Cost _name_=Utility)); */
/*   var electric gas water fuel; */
/*   by year homevalue state; */
/* run; */
/*  */
/* Problem: where is the legend? How do I fix the colors? */
/* ods select all; */
/* title 'Output 5.2.3: Fitted Curves for Utility Costs Versus Home Values'; */
/* proc sgpanel data=medianT; */
/* 	panelby state year / columns=3; */
/* 	pbspline x=homevalue y=cost / group=utility nolegfit nomarkers; */
/* 	colaxis label='Home Value x $1000' values=(0 to 400000 by 200000); */
/* 	rowaxis label='Cost ($)' values=(0 to 3000 by 1000); */
/* 	keylegend; */
/* run; */



/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// */


/* Figure 5.2.3 Method 2*/
ods select none;
proc report data=AllAll out=medians;
	column homevalue state year gas electric water fuel;
	define homevalue / group;
	define year / group;
	define state / group;
	define electric / median 'Median Electric';
	define gas / median 'Median Gas';
	define water / median 'Median Water';
	define fuel / median 'Median Fuel';
	where state in ('North Carolina', 'South Carolina');
run;

/* proc means data=medians max; */
/* run; */

ods select all;
proc sgpanel data=medians;
	panelby state year / columns=3 novarname;
	pbspline x=homevalue y=gas / legendlabel='Gas' nomarkers 
		smooth=100 lineattrs=(color=red thickness=2) ;
	pbspline x=homevalue y=electric / nomarkers legendlabel='Elec.' 
		smooth=100 lineattrs=(color=blue thickness=2);
	pbspline x=homevalue y=fuel / nomarkers legendlabel='Fuel' 
		smooth=100 lineattrs=(color=green thickness=2);
	pbspline x=homevalue y=water / nomarkers legendlabel='Water' 
		smooth=100 lineattrs=(color=orange thickness=2);
	colaxis values=(0 to 500000 by 200000) label='Home Value x$1000' 
		valuesdisplay=('0' '200' '400');
	rowaxis values=(0 to 3000 by 1000) label='Cost' valuesformat=best5.;
	keylegend;
run;







